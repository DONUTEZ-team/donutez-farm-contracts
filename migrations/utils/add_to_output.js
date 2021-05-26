require("dotenv").config();

const fs = require("fs");

const { createOutputFolder } = require("./create_output_folder");

function addToOutput(name, address, mode) {
  createOutputFolder();

  const result = address + " - " + name + "\n";

  if (mode === "WRITE") {
    fs.writeFile("./output/" + process.env.OUTPUT_FILE, result, function (err) {
      if (err) {
        return console.error(err);
      }
    });
  } else if (mode === "APPEND") {
    fs.appendFile(
      "./output/" + process.env.OUTPUT_FILE,
      result,
      function (err) {
        if (err) {
          return console.error(err);
        }
      }
    );
  }
}

module.exports = {
  addToOutput,
};
