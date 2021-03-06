###*
@class
Base class for embedded boards
###
class Board
  #----------------------------------------------------------------
  # Class attributes/methods

  ###*
  @protected
  Register board class
  ###
  @addBoard: (board) -> @_boards.push(board)

  ###*
  @private
  @property
  List of board classes
  ###
  @_boards: []

  #----------------------------------------------------------------
  # Instance attributes/methods

  ###*
  Get board information
  @param {Function} callback  Callback ({Boolean} result, {Object} info)
  ###
  getInfo: (callback) ->
    callback(true, {message: "No information for this board"})

  ###*
  Disconnect from board
  @param {Function} callback  Callback ({Boolean} result)
  ###
  disconnect: (callback) ->
    return callback(true) unless @isConnected
    @isConnected = false
    callback(true)

  ###*
  @property
  @readonly
  Connection state
  ###
  isConnected: false

  ###*
  @private
  Constructor
  ###
  constructor: @pureClass

  ###*
  [UI action] Refresh port list
  ###
  uiRefreshPorts: ->
    b = $("#group-board")
    p = $("#group-port")
    p.find(".list-item").remove()
    p.find(".list-refresh").unbind("click").click(=> @uiRefreshPorts())
    p.find(".btn").prop("disabled", true).find(".ph-body").empty()
    #  p.find(".btn").prop("disabled", false)
    index = 0
    portClass.enumerate((ports) =>
      return unless ports.length > 0
      for port in ports
        do (port) =>
          p.find(".list-alt").before("""
            <li class="list-item btn-xs">
              <a href="#" title="#{port.path}" id="port-item-#{index}">#{port.name}</a>
            </li>
            """
          )
          p.find("#port-item-#{index}").unbind("click").click(=>
            p.find(".ph-body").text(port.name)
            ModalSpin.show()
            @connect(port, (result) =>
              ModalSpin.hide()
              if result
                @port = port
                Notify.success("Connected #{@constructor.boardname} on #{port.name}")
              else
                @port = null
                Notify.error("Cannot connect #{@constructor.boardname} on #{port.name}")
              @constructor.uiChangeButtonState(result)
            )
          )
          p.find(".btn").prop("disabled", false) if index == 0
          index += 1
    ) for portClass in @constructor.portClasses

  ###*
  [UI action] Select new board
  ###
  @uiSelectNewBoard: (boardClass) ->
    b = $("#group-board")
    sketch = App.sketch
    unless sketch
      b.find(".ph-body").empty()
      return
    sketch.setBoard(boardClass, (result, board) =>
      return unless result
      @uiChangeButtonState(false)
      b.find(".ph-body").text(boardClass.boardname)
      board.uiRefreshPorts()
    )

  ###
  [UI initialization]
  ###
  $(=>
    b = $("#group-board")
    for boardClass in @_boards
      do (boardClass) =>
        b.find(".dropdown-menu").append("""
          <li class="btn-xs">
            <a href="#" id="board-item-#{boardClass.name\
            }" title="Author: #{boardClass.author\
            }&#10;Website: #{boardClass.website\
            }">#{boardClass.boardname}</a>
          </li>
          """
        )
        b.find("#board-item-#{boardClass.name}").unbind("click").click(=>
          @uiSelectNewBoard(boardClass)
        )
        b.find(".btn").prop("disabled", false)
  )

  ###
  [UI action] Enable board access
  ###
  @uiChangeButtonState: (enabled) ->
    $("#board-info").prop("disabled", !enabled)
    $("#run").prop("disabled", !enabled)

  ###*
  [UI action] Show board information
  ###
  uiShowInfo: ->
    ModalSpin.show()
    @getInfo((result, info) =>
      ModalSpin.hide()
      return Notify.error("Failed to get board information") unless result
      message = ("#{key}: #{val}" for key, val of info).join("<br/>")
      bootbox.alert({
        title: "Board information (#{@constructor.boardname} on #{@port.name})"
        message:message
      })
    )

  ###
  [UI event] Clicking "Board info" button
  ###
  $("#board-info").click(-> App.sketch?.board?.uiShowInfo())

  ###
  [UI event] Clicking "Run" button
  ###
  $("#run").click(->
    ModalSpin.show()
    Sketch.uiBuildSketch((result) ->
      sketch = App.sketch
      sketch.board.download(sketch, (result) ->
        ModalSpin.hide()
        Notify.success("Download succeeded") if result
      )
    )
  )

