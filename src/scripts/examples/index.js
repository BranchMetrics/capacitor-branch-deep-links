/* eslint-disable no-console */

// Prerequisites:
// Node/npm/npx
// ionic cli
// capacitor cli
// Xcode and AndroidStudio

// TESTING STEPS:
// cd into root folder
// `npm run examples`
// script will open project on Xcode and AndroidStudio
// Run apps

const { spawn } = require("child_process");

const DIR = "examples";
const TMP = "tmp";
const CAPACITORIONIC = "capacitor-ionic";
const CAPACITOR = "capacitor";

// promisfy bash execution with stout streaming
const run = (args, dir = undefined) =>
  new Promise(resolve => {
    const command = args.split(" ");
    const output = spawn(command.shift(), command, { cwd: dir });
    let stdout = "";
    output.stdout.on("data", data => {
      stdout += String(data);
      console.log(String(data));
    });

    output.stderr.on("data", data => {
      const error = String(data);
      console.log(error)
      if (error.toLowerCase().indexOf("error") !== -1) {
        throw new Error(String(data));
      }
    });
    output.on("close", () => resolve(stdout.trim()));
  });

const cleanDirectory = async () => {
  await run(`rm -rf ${TMP}`);
  await run(`rm -rf ${DIR}`);
  await run(`mkdir ${DIR}`);
};

const buildCapacitorIonic = async () => {
  await run(`ionic start ${CAPACITORIONIC} tabs --capacitor --type=angular --no-git --no-deps`, `${DIR}`);
  await run(`npm install --silent`, `${DIR}/${CAPACITORIONIC}`);
  await run(`npm install --save --silent ../../${TMP}`, `${DIR}/${CAPACITORIONIC}`);

  await run(
    `cp ./src/scripts/examples/templates/app.component.ts ./${DIR}/${CAPACITORIONIC}/src/app/app.component.ts`
  );

  await run(`npm run build`, `${DIR}/${CAPACITORIONIC}`);
  await run(`npx cap add ios`, `${DIR}/${CAPACITORIONIC}`);
  await run(`npx cap add android`, `${DIR}/${CAPACITORIONIC}`);

  await run(
    `cp ./src/scripts/examples/templates/ios/Info.plist ./${DIR}/${CAPACITORIONIC}/ios/App/App/Info.plist`
  );

  await run(
    `cp ./src/scripts/examples/templates/ios/AppDelegate.swift ./${DIR}/${CAPACITORIONIC}/ios/App/App/AppDelegate.swift`
  );

  await run(
    `cp ./src/scripts/examples/templates/android/AndroidManifest.xml ./${DIR}/${CAPACITORIONIC}/android/app/src/main/AndroidManifest.xml`
  );

  await run(
    `cp ./src/scripts/examples/templates/android/MainActivity.java ./${DIR}/${CAPACITORIONIC}/android/app/src/main/java/io/ionic/starter/MainActivity.java`
  );

  await run(`npx cap open ios`, `${DIR}/${CAPACITORIONIC}`);
  await run(`npx cap open android`, `${DIR}/${CAPACITORIONIC}`);
};

const buildCapacitor = async () => {
  await run(`npx @capacitor/cli create --npm-client=npm ${CAPACITOR} CapTest com.example.app`, `${DIR}`);
  await run(`npm install --save --silent ../../${TMP}`, `${DIR}/${CAPACITOR}`);

  await run(
    `cp ./src/scripts/examples/templates/capacitor-welcome.js ./${DIR}/${CAPACITOR}/www/js/capacitor-welcome.js`
  );

  await run(`npx cap add ios`, `${DIR}/${CAPACITOR}`);
  await run(`npx cap add android`, `${DIR}/${CAPACITOR}`);

  await run(
    `cp ./src/scripts/examples/templates/ios/Info.plist ./${DIR}/${CAPACITOR}/ios/App/App/Info.plist`
  );

  await run(
    `cp ./src/scripts/examples/templates/ios/AppDelegate.swift ./${DIR}/${CAPACITOR}/ios/App/App/AppDelegate.swift`
  );

  await run(
    `cp ./src/scripts/examples/templates/android/AndroidManifest.xml ./${DIR}/${CAPACITOR}/android/app/src/main/AndroidManifest.xml`
  );

  await run(
    `cp ./src/scripts/examples/templates/android/MainActivity.java ./${DIR}/${CAPACITOR}/android/app/src/main/java/com/example/app/MainActivity.java`
  );

  await run(`npx cap open ios`, `${DIR}/${CAPACITOR}`);
  await run(`npx cap open android`, `${DIR}/${CAPACITOR}`);
};

const copySdk = async () => {
  await run(
    `rsync -a ./ ./${TMP} --exclude node_modules --exclude .git --exclude ${DIR} --exclude ${TMP}`
  );
};

const main = async () => {
  await cleanDirectory();
  await copySdk();
  await buildCapacitorIonic();
  await buildCapacitor();
};

module.exports = main();
