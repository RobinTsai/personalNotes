const { log, dir } = require('console');
var walk = require('walk')
const fs = require('fs');
const path = require('path');
const ejs = require('ejs');


var excludeFilenames = ["vue", "syntax_learn"]

var projRoot = '/docs/'
var root = path.join(__dirname, projRoot)
console.log("root path is ", root)


function traverseDirectory(dirPath, level = 0) {
    const files = fs.readdirSync(dirPath);

    const result = files.map(file => {
        if (file.startsWith('.')) {
            return;
        }

        for (const exName of excludeFilenames) {
            if (exName == file) {
                return
            }
        }
        if (file.indexOf(".") != -1 && !(file.endsWith(".md") || file.endsWith(".MD"))) {
            return
         }

        const filePath = path.join(dirPath, file);
        const stats = fs.statSync(filePath);

        const fileInfo = {
            name: file,
            path: filePath,
            level: level,
            isDirectory: stats.isDirectory(),
        };

        if (stats.isDirectory()) {
            fileInfo.children = traverseDirectory(filePath, level + 1);
        }

        return fileInfo;
    });

    return result;
}

// 用法示例
const directoryPath = root;
const directoryMap = traverseDirectory(directoryPath);

function writeSummaryTable(dirs, level = 0) {
    dirs.forEach((item) => {
        if (!item) {
            return
        }

        if (item.isDirectory) {
            str = `${' '.repeat(4 * level)}* [${item.name.replace(/^(\d*_?)*_/g, '')}](${escape(item.path.replace(root, projRoot)) + "/README.md"})`
            fs.appendFileSync("SUMMARY.md", str + "\n")
            if (item.children) {
                writeSummaryTable(item.children, level + 1)
            }
        } else {
            if (item.name === 'README.md') {
                return
            }
            str = `${' '.repeat(4 * level)}* [${item.name.replace(".md", "").replace(/^\d*_/g, '')}](${escape(item.path.replace(root, projRoot))})`
            fs.appendFileSync("SUMMARY.md", str + "\n")
        }
    })
}

function writeSummary() {
    fs.writeFileSync("SUMMARY.md", "# Summary\n\n")
    fs.appendFileSync("SUMMARY.md", "<!--This is gen by gen_summary.js, DO NOT edit it by manual. -->\n\n")
    fs.appendFileSync("SUMMARY.md", "* [项目介绍](README.md)\n\n")
    writeSummaryTable(directoryMap)
}

writeSummary(directoryMap)
