{CompositeDisposable} = require 'atom'
WebFrame = require 'web-frame'
class Hidpi
  subscriptions: null
  currentScaleFactor: 1.0
  config:
    scaleFactor:
      title: 'Hidpi Scale Factor'
      type: 'number'
      default: 2.0
    defaultScaleFactor:
      title: 'Default Scale Factor'
      type: 'number'
      default: 1.0
    cutoffWidth:
      title: 'Cutoff Width'
      type: 'integer'
      default: 2300
    cutoffHeight:
      title: 'Cutoff Height'
      type: 'integer'
      default: 1500
    updateOnResize:
      title: 'Update On Resize'
      type: 'boolean'
      default: true
    reopenCurrentFile:
      title: 'Reopen Current File'
      type: 'boolean'
      default: false
    startupDelay:
      title: 'Startup Delay'
      type: 'integer'
      default: 200
    manualResolutionScaleFactors:
      title: 'Manual Resolution Scale Factors'
      type: 'string',
      default: ''
    osScaleFactor:
      title: 'Operating System Scale Factor'
      type: 'number',
      default: 1.0

  constructor: ->
      setTimeout(@update.bind(@), @config.startupDelay)
  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'hidpi:update': => @update()
    if @config.updateOnResize
      that = this
      window.onresize = (e) ->
        that.update()
  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
    hidpiViewState: @hidpiView.serialize()

  # Scale the interface when the current monitor's width is above "Cutoff Width"
  update: ->
    manualResolutions = @parseResolutions(atom.config.get 'hidpi.manualResolutionScaleFactors')
    osScaleFactor = atom.config.get 'hidpi.osScaleFactor'
    cutoffWidth = atom.config.get 'hidpi.cutoffWidth'
    cutoffHeight = atom.config.get 'hidpi.cutoffHeight'
    scaleFactor = atom.config.get 'hidpi.scaleFactor'
    defaultScaleFactor = atom.config.get 'hidpi.defaultScaleFactor'
    reopenCurrentFile = atom.config.get 'hidpi.reopenCurrentFile'

    adjustedScreenWidth = screen.width * osScaleFactor
    adjustedScreenHeight = screen.height * osScaleFactor
    manualResolutionScaleFactor = manualResolutions[''+adjustedScreenWidth+'x'+adjustedScreenHeight]
    previousScaleFactor = @currentScaleFactor
    console.log(''+adjustedScreenWidth+'x'+adjustedScreenHeight)
    console.log(manualResolutions)
    if manualResolutionScaleFactor
      @scale(manualResolutionScaleFactor)
    else if (adjustedScreenWidth > cutoffWidth) or (adjustedScreenHeight > cutoffHeight)
      @scale(scaleFactor)
    else
      @scale(defaultScaleFactor)

    if previousScaleFactor != @currentScaleFactor
      @reopenCurrent() if reopenCurrentFile

  parseResolutions: (resolutionString) ->
    resolutionRegex = /"?(\d*x\d*)"?:\s*(\d+\.?\d*)/g
    matches = {}
    match = resolutionRegex.exec(resolutionString)
    while match
      if match
        matches[match[1]] = parseFloat(match[2])
      match = resolutionRegex.exec(resolutionString)
    return matches

  scale: (factor) ->
    WebFrame.setZoomFactor(factor / atom.config.get 'hidpi.osScaleFactor')
    @currentScaleFactor = factor
  # Reopen the current file if it exists
  reopenCurrent: ->
    @activeEditor = atom.workspace.getActiveTextEditor()
    if @activeEditor
      @activePath = @activeEditor.getPath()
      atom.workspace.getActivePane().destroyActiveItem()
      if @activePath
        atom.workspace.open(@activePath)

module.exports = new Hidpi()
