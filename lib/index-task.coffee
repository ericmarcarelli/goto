
fs = require 'fs'
path = require 'path'
minimatch = require 'minimatch'

files = []

module.exports = (roots) ->
  callback = @async()

  for root in roots
    processDirectory(root.path)

  while files.length > 0
    emit('processFile', files.pop())
    sleep(2500)

  callback()

getFileTypeKey = (fqn) ->
  path.extname(fqn) || path.parse(fqn).base

processDirectory = (dirPath) ->
  dirs = []
  entries = fs.readdirSync(dirPath)

  for entry in entries
    fqn = path.join(dirPath, entry)
    try
      stats = fs.statSync(fqn)
      if keepPath(fqn,stats.isFile(),stats.isDirectory())
        if stats.isDirectory()
          dirs.push(fqn)
        else if stats.isFile()
          files.push(fqn)
    catch e
      continue

  entries = null

  for dir in dirs
    processDirectory(dir)

# TODO: Need to get something like SymbolIndex's keepPath working here.
keepPath = (filePath, isFile, isDirectory) ->
  if isDirectory
    return true
  fileType = getFileTypeKey(filePath)
  return (fileType is ".js" or fileType is ".php")

sleep = (ms) ->
  start = new Date().getTime()
  continue while new Date().getTime() - start < ms
