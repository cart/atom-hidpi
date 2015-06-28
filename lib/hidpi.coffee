{CompositeDisposable} = require 'atom'
WebFrame = require 'web-frame'
class Hidpi
  subscriptions: null
  currentScaleFactor: 1.0
  config:
    scaleFactor:
      title: 'Scale Factor'
      type: 'number'
      default: 2.0
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

  constructor: ->
      setTimeout(@update.bind(@), atom.config.get 'hidpi.startupDelay')
  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'hidpi:update': => @update()
    if atom.config.get 'hidpi.updateOnResize'
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
    manualResolutionScaleFactor = manualResolutions[''+screen.width+'x'+screen.height]
    previousScaleFactor = @currentScaleFactor
    if manualResolutionScaleFactor
      @scale(manualResolutionScaleFactor)
    else if (screen.width > atom.config.get 'hidpi.cutoffWidth') or (screen.height > atom.config.get 'hidpi.cutoffHeight')
      @scale(atom.config.get 'hidpi.scaleFactor')
    else
      @scale(1)

    if previousScaleFactor != @currentScaleFactor
      @reopenCurrent() if atom.config.get 'hidpi.reopenCurrentFile'

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
    WebFrame.setZoomFactor(factor)
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
