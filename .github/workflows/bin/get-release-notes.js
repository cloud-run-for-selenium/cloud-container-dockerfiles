const fs = require('fs');
const releaseNotesObj = JSON.parse(fs.readFileSync('./draft-release.json'));
const releaseNotes = releaseNotesObj.Releases[0].body;

console.log(releaseNotes + '\n\n');

