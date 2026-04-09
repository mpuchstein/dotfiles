; Jinja template injection queries
; Injects HTML into Jinja host language nodes

((text) @injection.content
 (#set! injection.language "html")
 (#set! injection.combined))
