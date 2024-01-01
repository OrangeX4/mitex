//! This is A command line interface for MiTeX. Available commands are (not yet
//! implemented):
//! - `compile`: transpiles a TeX document into a Typst document.
//!
//! # Usage
//! ```bash
//! mitex compile main.tex
//! # or (same output as above)
//! mitex compile main.tex main.typ
//! ```

use std::fs::{create_dir_all, File};
use std::path::Path;
use std::process::exit;
use std::sync::Arc;

use anyhow::Context;
use serde::{Deserialize, Serialize};

use mitex_cli::utils::{Error, UnwrapOrExit};
use mitex_cli::{
    get_cli, get_os_opts, intercept_version, CompileStage, CompletionArgs, SpecSubCommands,
    Subcommands,
};
use mitex_spec_gen::DEFAULT_SPEC;

fn help_sub_command() -> ! {
    get_os_opts(true).unwrap_or_exit();
    exit(0);
}

fn main() -> anyhow::Result<()> {
    let opts = get_os_opts(false).map_err(|err| err.exit()).unwrap();

    intercept_version(opts.version, opts.vv);

    match opts.sub {
        Some(Subcommands::Compile(args)) => {
            compile(
                &args.input,
                &args.output,
                matches!(args.stage, Some(CompileStage::Syntax)),
            )
            .unwrap_or_exit();
            exit(0);
        }
        Some(Subcommands::Completion(args)) => generate_completion(args),
        Some(Subcommands::Manual(args)) => {
            generate_manual(get_cli(true), &args.dest)
                .map_err(|err| {
                    let err: Error = err.to_string().into();
                    err
                })
                .unwrap_or_exit();
            exit(0);
        }
        Some(Subcommands::Spec(sub)) => match sub {
            SpecSubCommands::Generate(_args) => {
                generate();
                exit(0);
            }
        },
        None => help_sub_command(),
    };

    #[allow(unreachable_code)]
    {
        unreachable!("The subcommand must exit the process.");
    }
}

fn compile(input_path: &str, output_path: &str, is_ast: bool) -> Result<(), Error> {
    let input = std::fs::read_to_string(input_path)
        .with_context(|| format!("failed to read input file: {input_path}"))?;

    let output = if !is_ast {
        mitex::convert_math(&input, None).map_err(|e| anyhow::anyhow!("{}", e))
    } else {
        Ok(format!(
            "{:#?}",
            mitex_parser::parse(&input, DEFAULT_SPEC.clone())
        ))
    };

    let output = output.with_context(|| format!("failed to convert input file: {input_path}"))?;

    std::fs::write(output_path, output)?;

    Ok(())
}

fn generate() {
    // typst query --root . .\packages\latex-spec\mod.typ "<mitex-packages>"
    let project_root = std::env::var("CARGO_MANIFEST_DIR").unwrap();
    let project_root = std::path::Path::new(&project_root)
        .parent()
        .unwrap()
        .parent()
        .unwrap();

    let target_dir = project_root.join("target/mitex-artifacts");

    let package_specs = std::process::Command::new("typst")
        .args([
            "query",
            "--root",
            project_root.to_str().unwrap(),
            project_root
                .join("packages/mitex/specs/mod.typ")
                .to_str()
                .unwrap(),
            "<mitex-packages>",
        ])
        .output()
        .expect("failed to query metadata");

    #[derive(Clone, Debug, Serialize, Deserialize, PartialEq)]
    struct QueryItem<T> {
        pub value: T,
    }

    type Json<T> = Vec<QueryItem<T>>;

    let mut json_spec: mitex_spec::JsonCommandSpec = Default::default();
    let json_packages: Json<mitex_spec::query::PackagesVec> =
        serde_json::from_slice(&package_specs.stdout).expect("failed to parse package specs");
    if json_packages.is_empty() {
        panic!("no package found");
    }
    if json_packages.len() > 1 {
        panic!("multiple packages found");
    }

    std::fs::create_dir_all(target_dir.join("spec")).unwrap();

    let json_packages = json_packages.into_iter().next().unwrap().value;
    std::fs::write(
        target_dir.join("spec/packages.json"),
        serde_json::to_string_pretty(&json_packages).unwrap(),
    )
    .unwrap();

    for package in json_packages.0 {
        for (name, item) in package.spec.commands {
            json_spec.commands.insert(name, item);
        }
    }
    std::fs::write(
        target_dir.join("spec/default.json"),
        serde_json::to_string_pretty(&json_spec).unwrap(),
    )
    .unwrap();

    let spec: mitex_spec::CommandSpec = json_spec.into();

    std::fs::write(target_dir.join("spec/default.rkyv"), spec.to_bytes()).unwrap();
}

fn generate_completion(CompletionArgs { shell }: CompletionArgs) -> ! {
    clap_complete::generate(shell, &mut get_cli(true), "mitex", &mut std::io::stdout());
    exit(0);
}

fn generate_manual(cmd: clap::Command, out: &Path) -> Result<(), Box<dyn std::error::Error>> {
    use clap_mangen::Man;

    create_dir_all(out)?;

    Man::new(cmd.clone()).render(&mut File::create(out.join("mitex-cli.1")).unwrap())?;

    let mut borrow_str = vec![];

    for subcmd in cmd.get_subcommands() {
        let name: Arc<str> = format!("mitex-cli-{}", subcmd.get_name()).into();
        Man::new(subcmd.clone().name({
            // we need it since clap mangen doesn't support dynamic subcommand name
            // Safety: `name` is a not freed until the end of the program
            unsafe { std::mem::transmute::<&str, &'static str>(name.as_ref()) }
        }))
        .render(&mut File::create(out.join(format!("{name}.1")))?)?;
        borrow_str.push(name);
    }

    Ok(())
}
