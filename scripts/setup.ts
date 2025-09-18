import $ from "https://deno.land/x/dax@0.39.2/mod.ts";
import { confirm } from "npm:@inquirer/prompts@4.3.2";

// set -f

if (Deno.env.get("USER") !== "root") {
  console.error("This script must be run as root.");
  Deno.exit(1);
}

const REPO_DIR =
  Deno.env.get("REPO_DIR") ||
  `${Deno.env.get("HOME")}/ghq/github.com/hir0o/dotfiles`;
const XDG_CONFIG_HOME =
  Deno.env.get("XDG_CONFIG_HOME") || `${Deno.env.get("HOME")}/.config`;

async function setup() {
  try {
    await $`brew --version`.quiet();
    console.log("Homebrew is already installed.");
  } catch {
    console.log("Installing Homebrew...");
    await $`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"`;
  }

  const updateBrew = await confirm({
    message: "Do you want to update Homebrew?",
  });
  if (updateBrew) {
    await $`brew update`;
  }

  const installBrewBundle = await confirm({
    message: "Do you want to install Brewfile?",
  });
  if (installBrewBundle) {
    await $`brew bundle install --file ${REPO_DIR}/config/homebrew/Brewfile`;
  }

  const setupLinks = await confirm({
    message: "Do you want to set up symbolic links?",
  });
  if (setupLinks) {
    console.log("Setting up links...");
    await $`ln -sfv ${REPO_DIR}/config/* ${XDG_CONFIG_HOME}`;
    await $`ln -sfv ${XDG_CONFIG_HOME}/zsh/.zshenv ${Deno.env.get(
      "HOME"
    )}/.zshenv`;

    const VSCODE_PATH = `${Deno.env.get(
      "HOME"
    )}/Library/Application\\ Support/Code/User`;
    // const CURSOR_PATH = `${Deno.env.get(
    //   "HOME"
    // )}/Library/Application\\ Support/Cursor/User`;

    const files = await $`ls ${XDG_CONFIG_HOME}/vscode/`.lines();
    console.log(files);

    for await (const file of files) {
      await $`ln -sfv ${XDG_CONFIG_HOME}/vscode/${file} ${VSCODE_PATH}/${file}`;
    }

    // ファイルをリンク
    // await $`find ${XDG_CONFIG_HOME}/vscode -type f -exec ln -sfnv "{}" "${VSCODE_PATH}/{}" \\;`;
    // await $`find ${XDG_CONFIG_HOME}/vscode -type f -exec ln -sfnv "{}" "${CURSOR_PATH}/{}" \\;`;
  }
}

await setup()
  .then(() => {
    Deno.exit(0);
  })
  .catch((err) => {
    console.error("Setup failed:", err);
    Deno.exit(1);
  });
