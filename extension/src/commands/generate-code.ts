import { commands, OpenDialogOptions, Uri, window } from 'vscode';
import { debugLogChannel } from '../main';
export const command = 'bigorm.model.generateCode';

const options: OpenDialogOptions = {
    canSelectMany: false,
    openLabel: 'Select',
    canSelectFiles: false,
    canSelectFolders: true
};

export default async function generateCode() {
    await commands.executeCommand("workbench.action.files.saveAll");
    const language = await window.showQuickPick(['Hibernate', 'SQLAlchemy', 'Entity Framework'], {
        placeHolder: 'Select language to generate code for.'
    });
    window.showInformationMessage(`Got: ${language}`);
    const activeEditor = window.activeTextEditor;

    // TODO implement other code generators
    if (language === 'Entity Framework') {
        debugLogChannel.appendLine("Only hibernate & SqlAlchemy supported currently");
        return;
    }

    if (!activeEditor || !activeEditor.document || activeEditor.document.languageId !== 'bigorm') {
        debugLogChannel.appendLine("Can't execute command");
        return;
    }

    const folder = await window.showOpenDialog(options);

    if (!(folder && folder[0])) {
        debugLogChannel.appendLine("No folder selected");
        return;
    }
    debugLogChannel.appendLine('Selected folder: ' + folder[0]);

    if (activeEditor.document.uri instanceof Uri) {
        const args = {"file": activeEditor.document.uri.toString(), "language": language, "outputPath": folder[0].toString()};
        commands.executeCommand("big.orm.command.generate", args).then(((answer) => { debugLogChannel.appendLine(String(answer)); }));
    }
}