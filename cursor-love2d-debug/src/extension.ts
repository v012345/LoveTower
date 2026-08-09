import * as vscode from 'vscode';
import { LoveDebugSession } from './loveDebugSession';

export function activate(context: vscode.ExtensionContext) {
    context.subscriptions.push(
        vscode.debug.registerDebugConfigurationProvider('love2d', {
            resolveDebugConfiguration(folder, config) {
                // 用户直接按 F5 且没有 launch.json 时给一份默认配置
                if (!config.type && !config.request) {
                    config.type = 'love2d';
                    config.request = 'launch';
                    config.name = 'Debug Love2D';
                }
                if (!config.projectRoot) {
                    config.projectRoot = folder?.uri.fsPath ?? '${workspaceFolder}';
                }
                return config;
            },
        }),
        vscode.debug.registerDebugAdapterDescriptorFactory('love2d', {
            createDebugAdapterDescriptor() {
                return new vscode.DebugAdapterInlineImplementation(
                    new LoveDebugSession(context.extensionPath)
                );
            },
        })
    );
}

export function deactivate() {}
