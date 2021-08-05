require("dotenv").config();

const { program } = require("commander");
const { exec, execSync } = require("child_process");
const fs = require("fs");

const getLigo = (isDockerizedLigo) => {
  let path = "ligo";

  if (isDockerizedLigo) {
    path = "docker run -v $PWD:$PWD --rm -i ligolang/ligo:0.20.0";

    try {
      execSync(`${path}  --help`);
    } catch (err) {
      console.log("Trying to use global version...");
      path = "ligo";
      execSync(`${path}  --help`);
    }
  } else {
    try {
      execSync(`${path}  --help`);
    } catch (err) {
      console.log("Trying to use dockerized version...");
      path = "docker run -v $PWD:$PWD --rm -i ligolang/ligo:0.20.0";
      execSync(`${path}  --help`);
    }
  }

  return path;
};

const buildContract = (
  contractName,
  inputDir,
  outputDir,
  jsonFormat,
  isDockerizedLigo
) => {
  let ligo = getLigo(isDockerizedLigo);

  exec(
    `${ligo} compile-contract ${
      jsonFormat ? "--michelson-format=json" : ""
    } $PWD/${inputDir}/${contractName}.ligo main`,
    { maxBuffer: 1024 * 10000 },
    (err, stdout) => {
      if (err) {
        console.log(`Error during ${contractName} building`);
        console.log(err);
      } else {
        console.log(`${contractName} built`);
        fs.writeFileSync(
          `./${outputDir}/${contractName}.${jsonFormat ? "json" : "tz"}`,
          stdout
        );
      }
    }
  );
};

program.version("0.1.0");

program
  .command("build-farming")
  .description("builds Yield Farming contract")
  .option("-o, --output_dir <dir>", "Where store builds", "build")
  .option("-i, --input_dir <dir>", "Where files are located", "contracts/main")
  .option("-j, --no-json", "The format of output file")
  .option("-g, --no-dockerized_ligo", "Switch to global ligo")
  .action(function (options) {
    let contractName = `farming`;

    exec("mkdir -p " + options.output_dir);
    buildContract(
      contractName,
      options.input_dir,
      options.output_dir,
      options.json,
      options.dockerized_ligo
    );
  });

program
  .command("build-fa12-token")
  .description("builds FA12 token contract")
  .option("-o, --output_dir <dir>", "Where store builds", "build")
  .option("-i, --input_dir <dir>", "Where files are located", "contracts/main")
  .option("-j, --no-json", "The format of output file")
  .option("-g, --no-dockerized_ligo", "Switch to global ligo")
  .action(function (options) {
    let contractName = `fa12`;

    exec("mkdir -p " + options.output_dir);
    buildContract(
      contractName,
      options.input_dir,
      options.output_dir,
      options.json,
      options.dockerized_ligo
    );
  });

program.parse(process.argv);
