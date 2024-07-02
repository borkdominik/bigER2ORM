import * as path from 'path';
import { commands, OpenDialogOptions, Uri, window, workspace } from 'vscode';
import { debugLogChannel } from '../main';
export const command = 'bigorm.model.reverseToModel';

const optionsInput: OpenDialogOptions = {
    canSelectMany: false,
    openLabel: 'Select as input',
    canSelectFiles: true,
    canSelectFolders: true
    // TODO: ,title: 'Select files to reverse'
};

const optionsOutput: OpenDialogOptions = {
    canSelectMany: false,
    openLabel: 'Select for output',
    canSelectFiles: false,
    canSelectFolders: true
    // TODO: ,title: 'Select output folder'
};

export default async function reverseToModel() {
    const fileInput = await window.showOpenDialog(optionsInput);

    if (!(fileInput && fileInput[0])) {
        debugLogChannel.appendLine("No file selected");
        return;
    }
    debugLogChannel.appendLine('Selected file: ' + fileInput[0].toString());

    const fileOutputPath = await window.showOpenDialog(optionsOutput);

    if (!(fileOutputPath && fileOutputPath[0])) {
        debugLogChannel.appendLine("No output path selected");
        return;
    }
    debugLogChannel.appendLine('Selected output path: ' + fileOutputPath[0].toString());

    const modelName = await window.showInputBox({
        placeHolder: 'Select name of model to create'
    });
    if (!modelName) {
        debugLogChannel.appendLine("No model name entered");
        return;
    }
    debugLogChannel.appendLine('Model name: ' + modelName);

    const args = {"fileInput": fileInput[0].toString(), "fileOutput": fileOutputPath[0].toString(), "modelName": modelName};
    const answer = await commands.executeCommand("big.orm.command.reverse", args);
    debugLogChannel.appendLine(String(answer));

    const filePath = path.join(fileOutputPath[0].path, modelName + ".orm");
    const openPath = Uri.file(filePath);
    workspace.openTextDocument(openPath).then(doc => {
        window.showTextDocument(doc);
    });
}