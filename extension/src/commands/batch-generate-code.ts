import * as fs from "fs";
import * as path from "path";
import { commands, OpenDialogOptions, Uri, window } from 'vscode';
import { debugLogChannel } from '../main';
import { languageOptions } from "./generate-code";
export const command = 'bigorm.model.batchGenerateCode';

const options: OpenDialogOptions = {
    canSelectMany: false,
    openLabel: 'Select',
    canSelectFiles: false,
    canSelectFolders: true
};

export default async function batchGenerateCode() {
    const folder = await window.showOpenDialog(options);

    if (!(folder && folder[0])) {
        debugLogChannel.appendLine("No folder selected");
        return;
    }
    debugLogChannel.appendLine('Selected folder: ' + folder[0]);

    const folderPath = folder[0].fsPath;
    const entries = fs.readdirSync(folderPath, { withFileTypes: true });
    // Filter for files (not directories) that end with ".orm"
    const ormFiles = entries
        .filter(e => e.isFile() && e.name.toLowerCase().endsWith(".orm"))
        .map(e => ({
            fileUri: Uri.file(path.join(folderPath, e.name)),
            name: path.parse(e.name).name,
        }));

    if (ormFiles.length === 0) {
        debugLogChannel.appendLine("No .orm files found directly in folder.");
        return;
    }

    // Loop through the files
    for (const {fileUri, name} of ormFiles) {
        debugLogChannel.appendLine("Found .orm file: " + fileUri);

        const subfolderPath = path.join(folderPath, name);
        const subfolderUri = Uri.file(subfolderPath);

        // If folder exists, delete it
        if (fs.existsSync(subfolderPath)) {
            fs.rmSync(subfolderPath, { recursive: true, force: true });
            debugLogChannel.appendLine("Deleted existing folder: " + subfolderUri.toString());
        }

        // Create folder for all lanugage generations for file
        fs.mkdirSync(subfolderPath);
        debugLogChannel.appendLine("Created new folder: " + subfolderUri.toString());

        for (const languageOption of languageOptions) {
            generateForLanguage(languageOption, subfolderPath, fileUri);
        }
    }
}


function generateForLanguage(language: {name: string, folderName: string}, targetFolder: string, modelUri: Uri) {
    // Create folder
    const targetSubfolder = path.join(targetFolder, language.folderName);
    const targetSubfolderUri = Uri.file(targetSubfolder);
    fs.mkdirSync(targetSubfolder);
    debugLogChannel.appendLine("Created new folder for language: " + targetSubfolderUri);

    debugLogChannel.appendLine(`Generating code for ${modelUri} in ${language.name}`);
    const args = {"file": modelUri.toString(), "language": language.name, "outputPath": targetSubfolderUri.toString()};
    commands.executeCommand("big.orm.command.generate", args).then(((answer) => { debugLogChannel.appendLine(String(answer)); }));
}