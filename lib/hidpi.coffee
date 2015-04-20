{CompositeDisposable} = require 'atom'
class Hidpi
  subscriptions: null
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
      default: true
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
    manual_resolutions = JSON.parse('{'+(atom.config.get 'hidpi.manualResolutionScaleFactors')+'}')
    manual_resolution = manual_resolutions[''+screen.width+'x'+screen.height]
    if manual_resolution
      require('web-frame').setZoomFactor(manual_resolution)
    else if (screen.width > atom.config.get 'hidpi.cutoffWidth') or (screen.height > atom.config.get 'hidpi.cutoffHeight')
      require('web-frame').setZoomFactor(atom.config.get 'hidpi.scaleFactor')
    else
      require('web-frame').setZoomFactor(1)

    # console.log screen.width
    @reopenCurrent() if atom.config.get 'hidpi.reopenCurrentFile'

  # Reopen the current file if it exists
  reopenCurrent: ->
    @activeEditor = atom.workspace.getActiveTextEditor()
    if @activeEditor
      @activePath = @activeEditor.getPath()
      atom.workspace.getActivePane().destroyActiveItem()
      if @activePath
        atom.workspace.open(@activePath)

module.exports = new Hidpi()
