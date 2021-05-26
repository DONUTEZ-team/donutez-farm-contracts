const fs = require("fs");
const path = require("path");

function createOutputFolder() {
  fs.mkdir(
    path.join(__dirname, "..", "..", "output"),
    { recursive: true },
    (err) => {
      if (err) {
        return console.error(err);
      }
    }
  );
}

module.exports = {
  createOutputFolder,
};
