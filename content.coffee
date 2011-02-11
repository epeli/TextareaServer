


do ->

    timeStamp = (new Date().getTime())
    siteId = ->
        location.href.replace(/[^a-zA-Z]/g, "") + "_" + timeStamp

    $.fn.edited = (callback) ->
        this.each ->
            active = false

            e = this
            $e = $(e)

            $e.focusin ->
                active = true
            $e.focusout ->
                active = false

            $(window).keyup ->
                callback(e) if active



    $.fn.uuid = ->
        e =  $(this.get(0))
        uuid = e.data("uuid")
        if uuid
            return uuid
        else
            $.fn.uuid.counter += 1
            uuid = siteId() + "_" + $.fn.uuid.counter
            e.data("uuid", uuid)
            return uuid
    $.fn.uuid.counter = 0


    $.fn.editInExternalEditor = (port) ->
        that = $(this)

        if that.data "server"
            return
        that.data "server", true

        sendToEditor = (spawn=false) ->
            port.postMessage
                textarea: that.val()
                uuid: that.uuid()
                spawn: spawn
                action: "open"

        that.edited ->
            sendToEditor()

        sendToEditor(true)




textAreas = {}


port = chrome.extension.connect  name: "textareapipe"
port.onMessage.addListener (obj) ->
    textarea = textAreas[obj.uuid]
    textarea.val obj.textarea


# Listen contextmenu clicks
chrome.extension.onRequest.addListener (req, sender) ->
    if req.action is "edittextarea"

        console.log "frame #{ req.onClickData.frameUrl } page #{ req.onClickData.pageUrl} #{ window.location.href  } "

        realUrl = req.onClickData.frameUrl || req.onClickData.pageUrl
        if realUrl isnt window.location.href
            return
        
        textarea = $(document.activeElement)
        textAreas[textarea.uuid()] = textarea
        textarea.editInExternalEditor(port)


$(window).unload ->

    port.postMessage
        action: "delete_all"
        uuid: [ta.uudi() for key, ta of ta.uuid()]






