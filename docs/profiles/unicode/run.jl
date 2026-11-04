using EHTColorSchemes
using UnicodePlots

stage = only(ARGS)
mkpath(stage)
scheme = colorscheme(:copper_u)
UnicodePlots.truecolors!()
plot = UnicodePlots.heatmap([sin(x) * cos(y) for x in 1:20, y in 1:20];
    colormap = [(color.r, color.g, color.b) for color in scheme.colors],
    title = "copper_u")

terminal = sprint(io -> show(IOContext(io, :color => true), MIME("text/plain"), plot))
write(joinpath(stage, "unicodeplots.txt"), terminal)

function html_escape(text)
    replace(text, "&" => "&amp;", "<" => "&lt;", ">" => "&gt;", '"' => "&quot;")
end

function ansi_to_svg(terminal)
    body = IOBuffer()
    foreground = nothing
    background = nothing
    column = 0
    row = 0
    widest = 0
    char_width = 9
    line_height = 18
    padding = 12

    color_value(color) = "rgb($(color[1]), $(color[2]), $(color[3]))"

    function write_text(text)
        for character in text
            if character == '\n'
                widest = max(widest, column)
                column = 0
                row += 1
            else
                x = padding + column * char_width
                y = padding + (row + 1) * line_height - 4
                background !== nothing && print(body,
                    "<rect x=\"$x\" y=\"$(y - line_height + 4)\" width=\"$char_width\" height=\"$line_height\" fill=\"$(color_value(background))\"/>")
                fill = foreground === nothing ? "currentColor" : color_value(foreground)
                print(body, "<text x=\"$x\" y=\"$y\" fill=\"$fill\">", html_escape(string(character)), "</text>")
                column += 1
            end
        end
    end

    position = firstindex(terminal)
    for matched in eachmatch(r"\e\[([0-9;]*)m", terminal)
        write_text(terminal[position:prevind(terminal, matched.offset)])
        codes = isempty(matched.captures[1]) ? Int[0] : parse.(Int, split(matched.captures[1], ';'))
        index = 1
        while index <= length(codes)
            code = codes[index]
            if code == 0
                foreground = nothing
                background = nothing
            elseif code == 39
                foreground = nothing
            elseif code == 49
                background = nothing
            elseif code == 38 && index + 4 <= length(codes) && codes[index + 1] == 2
                foreground = (codes[index + 2], codes[index + 3], codes[index + 4])
                index += 4
            elseif code == 48 && index + 4 <= length(codes) && codes[index + 1] == 2
                background = (codes[index + 2], codes[index + 3], codes[index + 4])
                index += 4
            end
            index += 1
        end
        position = matched.offset + ncodeunits(matched.match)
    end
    write_text(terminal[position:end])
    widest = max(widest, column)
    width = 2 * padding + widest * char_width
    height = 2 * padding + max(row, 1) * line_height
    return """<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"$width\" height=\"$height\" viewBox=\"0 0 $width $height\" role=\"img\" aria-label=\"UnicodePlots copper_u terminal rendering\">
<style>svg { background: #fff; color: #222; } text { font: 14px JuliaMono, ui-monospace, SFMono-Regular, Menlo, monospace; } @media (prefers-color-scheme: dark) { svg { background: #1e1e1e; color: #e6e6e6; } }</style>
$(String(take!(body)))</svg>"""
end

write(joinpath(stage, "unicodeplots.svg"), ansi_to_svg(terminal))
