Attribute VB_Name = "NewMacros"
'
' Macros para word
' Todo:
'   Utilizar las flechitas para cambiar de tono y cambiar saturacion
'
    
Public colorActual As color_struct
'Cambiando el H = Hue obtengo diferentes tonos
'cambiando V y S obtengo diferentes saturaciones y brillos
'Luego tengo que ejecutar setHSVcolor para leer el nuemro y poner el color

Public guardarPaleta As Boolean 'Seleccionador de paleta
Public showMSG As Boolean 'si muestra o no los mensajes de informacion

Public pagPaleta As Integer, numPaleta As Byte 'pagina, numero, almacenamiento
Public memPaleta(5, 3) As color_struct 'filas son las paginas, columnas el numero/indice del color
Public initMem As Boolean 'Flag que arranca en false y se activa al usar las paginas de paletas de colores

Public Type color_struct
     H As Double 'entre 0 y 360
     S As Double 'entre 0 y 1
     V As Double 'entre 0 y 1
     r As Integer
     g As Integer
     b As Integer
End Type

Sub setHSVcolor()
'H = 34/360
'Call setHSVcolor
    Dim color As color_struct
    color = hsv2rgb(colorActual.H, colorActual.S, colorActual.V)
    Selection.Font.color = rgb(color.r, color.g, color.b)
End Sub

'Sub setRGBColor(hexNum As String)
''setColor ("F69698")
'Dim r As Integer, G As Integer, B As Integer
'r = CInt("&H" & Mid(hexNum, 1, 2))
'G = CInt("&H" & Mid(hexNum, 3, 2))
'B = CInt("&H" & Mid(hexNum, 5, 2))

'Selection.Font.color = RGB(r, G, B)
'End Sub
Sub toggleColor(H1, H2)
    Dim color As color_struct
    colorActual.S = 1
    colorActual.V = 1
    color = getColorWord()
    If color.H = H1 Then
        colorActual.H = H2 'toggle al color 2 adimensional
    Else
        colorActual.H = H1 'Si estaba en el color 2 o algun otro, vuelvo al color 1
    End If
    
    Call setHSVcolor
End Sub
Sub accederPaleta()
'guarda o accede a la paleta mediante las variables globales:
'pagPaleta: la pagina de la paleta (cada pagina tiene 3 colores)
'numPaleta: posicion del color dentro de la paleta
'memPaleta: La memoria donde se guardan las paletas
    If initMem = False Then 'Guarda la paleta desde la ultima vez que se abrio el word
        Call loadMem
        initMem = True
    End If
    If guardarPaleta Then
        Call savePaleta
        guardarPaleta = False
        If showMSG Then
            MsgBox "Guardado"
        End If
    Else
        Call setPaleta
    End If
End Sub
Sub savePaleta()
    'selecciono paleta y la guardo
    Dim color As color_struct
    color.H = colorActual.H
    color.S = colorActual.S
    color.V = colorActual.V
    memPaleta(pagPaleta, numPaleta) = color
    Call saveMem
End Sub
Sub setPaleta()
    'selecciono paleta y la aplico
    Dim color As color_struct
    color = memPaleta(pagPaleta, numPaleta)
    colorActual.H = color.H
    colorActual.S = color.S
    colorActual.V = color.V
    Call setHSVcolor
End Sub
Sub saveMem()
    'Actualiza la memoria de paleta de colores
    Dim posName As String
    For i = 0 To 4
        For j = 0 To 2
            posName = "memPaleta" & "(" & i & "," & j & ")." & "H"
            ActiveDocument.Variables(posName).Delete
            ActiveDocument.Variables.Add posName, Value:=memPaleta(i, j).H
            posName = "memPaleta" & "(" & i & "," & j & ")." & "S"
            ActiveDocument.Variables(posName).Delete
            ActiveDocument.Variables.Add posName, Value:=memPaleta(i, j).S
            posName = "memPaleta" & "(" & i & "," & j & ")." & "V"
            ActiveDocument.Variables(posName).Delete
            ActiveDocument.Variables.Add posName, Value:=memPaleta(i, j).V

        Next j
    Next i
End Sub
Sub loadMem()
'Rutina de inicializacion
    Dim posName As String
    Dim color As color_struct
    showMSG = True 'Activo los mensajes
    If ActiveDocument.Variables.Count = 0 Then
        MsgBox "anadiendo variables de paleta de colores al documento"
        For i = 0 To 4 'Pagina
            For j = 0 To 2 'Numero
                posName = "memPaleta" & "(" & i & "," & j & ")." & "H"
                ActiveDocument.Variables.Add posName, Value:=memPaleta(i, j).H
                posName = "memPaleta" & "(" & i & "," & j & ")." & "S"
                ActiveDocument.Variables.Add posName, Value:=memPaleta(i, j).S
                posName = "memPaleta" & "(" & i & "," & j & ")." & "V"
                ActiveDocument.Variables.Add posName, Value:=memPaleta(i, j).V
            Next j
        Next i
    End If
    For i = 0 To 4 'Pagina
        For j = 0 To 2 'Numero
            posName = "memPaleta" & "(" & i & "," & j & ")." & "H"
            color.H = ActiveDocument.Variables(posName).Value
            posName = "memPaleta" & "(" & i & "," & j & ")." & "S"
            color.S = ActiveDocument.Variables(posName).Value
            posName = "memPaleta" & "(" & i & "," & j & ")." & "V"
            color.V = ActiveDocument.Variables(posName).Value
            memPaleta(i, j) = color
        Next j
    Next i
End Sub
Sub updatePag()
    For i = 3 To 4 'Pagina
        For j = 0 To 2 'Numero
            posName = "memPaleta" & "(" & i & "," & j & ")." & "H"
            ActiveDocument.Variables.Add posName, Value:=memPaleta(i, j).H
            posName = "memPaleta" & "(" & i & "," & j & ")." & "S"
            ActiveDocument.Variables.Add posName, Value:=memPaleta(i, j).S
            posName = "memPaleta" & "(" & i & "," & j & ")." & "V"
            ActiveDocument.Variables.Add posName, Value:=memPaleta(i, j).V
        Next j
    Next i
End Sub

Public Function max(x As Integer, y As Integer, z As Integer) As Integer
    Dim ret As Integer
    If x >= y Then
        If x > z Then
            ret = x
        Else
            ret = z
        End If
    ElseIf y > z Then
        ret = y
    Else
        ret = z
    End If
    max = ret
End Function
Public Function min(x As Integer, y As Integer, z As Integer) As Integer
    Dim ret As Integer
    If x <= y Then
        If x <= z Then
            ret = x
        Else
            ret = z
        End If
    ElseIf y <= z Then
        ret = y
    Else
        ret = z
    End If
    min = ret
End Function
Public Function getColorWord() As color_struct
    'lee el color de la seleccion y lo devuelve en RGB HSV
    Dim color As Long
    Dim r As Integer, g As Integer, b As Integer
    color = Selection.Font.color
    r = &HFF& And color
    g = (&HFF00& And color) \ 256
    b = (&HFF0000 And color) \ 65536
    getColorWord = rgb2hsv(r, g, b)
End Function
Public Function getHword() As Double
    Dim color As color_struct
    color = getColorWord()
    getHword = color.H
End Function
Public Function rgb2hsv(r As Integer, g As Integer, b As Integer) As color_struct
    Dim retH As Double, retS As Double, retV As Double
    Dim mx As Integer, mn As Integer
    
    mx = max(r, g, b)
    mn = min(r, g, b)
    df = mx - mn
    If mx = mn Then
        retH = 0
    ElseIf mx = r Then
        retH = (60 * ((g - b) / df) + 360) Mod 360
    ElseIf mx = g Then
        retH = (60 * ((b - r) / df) + 120) Mod 360
    ElseIf mx = b Then
        retH = (60 * ((r - g) / df) + 240) Mod 360
    End If
    If mx = 0 Then
        retS = 0
    Else
        retS = df / mx
    End If
    retV = mx / 255
    rgb2hsv.r = r
    rgb2hsv.g = g
    rgb2hsv.b = b
    rgb2hsv.H = retH
    rgb2hsv.S = retS
    rgb2hsv.V = retV
End Function
Public Function hsv2rgb(H As Double, S As Double, V As Double) As color_struct
    Dim i As Integer, f As Double
    Dim P As Double, q As Double, t As Double
    Dim retR As Integer, retG As Integer, retB As Integer, retH As Double
    If S > 1 Then
        S = 1
    ElseIf S < 0 Then
        S = 0
    End If
    If V > 1 Then
        V = 1
    ElseIf V < 0 Then
        V = 0
    End If
    If H > 360 Then
        H = 360
    ElseIf H < 0 Then
        H = 0
    End If
    
    If S = 0 Then
        retR = V * 255
        retG = V * 255
        retB = V * 255
    Else
        i = Fix(6 * H / 360)
        f = 6 * H / 360 - i
        P = V * (1 - S)
        q = V * (1 - S * f)
        t = V * (1 - S * (1 - f))
        i = i Mod 6
        Select Case i
            Case 0
                retR = V * 255
                retG = t * 255
                retB = P * 255
            Case 1
                retR = q * 255
                retG = V * 255
                retB = P * 255
            Case 2
                retR = P * 255
                retG = V * 255
                retB = t * 255
            Case 3
                retR = P * 255
                retG = q * 255
                retB = V * 255
            Case 4
                retR = t * 255
                retG = P * 255
                retB = V * 255
            Case 5
                retR = V * 255
                retG = P * 255
                retB = q * 255
        End Select
    End If
    hsv2rgb.H = H
    hsv2rgb.S = S
    hsv2rgb.V = V
    hsv2rgb.r = retR
    hsv2rgb.g = retG
    hsv2rgb.b = retB
End Function

Sub getColor()
    'Asignar al intro, en hsv
    Dim txt As String
    Dim color As color_struct
    color = getColorWord()
    txt = "H: " & color.H & "   S: " & color.S & "   V: " & color.V
    'txt = "R:" & Hex(R) & " G:" & Hex(G) & " B:" & Hex(B)
    If showMSG Then
        MsgBox txt & vbCrLf & vbCrLf & "Presione 0 y una memoria para guardar el color"
    End If
    colorActual.H = color.H
    colorActual.S = color.S
    colorActual.V = color.V
End Sub

Sub Negrita()
    Selection.Font.Bold = wdToggle
End Sub

'Sub BlancoNegro()
'End Sub
Sub RojoNaranja()
Attribute RojoNaranja.VB_ProcData.VB_Invoke_Func = "Normal.NewMacros.Rojo"
    'Asignar al shortcut ctrl+alt+num1
    Call toggleColor(0, 25) 'Alterno entre rojo y naranja
End Sub
Sub AmarilloVerdeManzana()
    'Asignar al 4
    Call toggleColor(60, 90) 'Alterno entre amarillo y verde manzana
End Sub
Sub VerdeOscuroTurquesa()
    'Asignar al 2
    Call toggleColor(130, 160) 'Alterno entre verde oscuro y turquesa
End Sub
Sub CyanCeleste()
    'Asignar al 5
    Call toggleColor(180, 200) 'Alterno entre cyan y celeste
End Sub
Sub AzulVioleta()
    'Asignar al 3
    Call toggleColor(245, 280) 'Alterno entre azul y violeta
End Sub
Sub MagentaRosa()
    'Asignar al 6
    Call toggleColor(300, 330) 'Alterno entre magenta y rosa
End Sub

Sub saturacionUp()
    'Asignar al -
    colorActual.S = colorActual.S + 0.2
    If colorActual.S > 1 Then
        colorActual.S = 1
    End If
    Call setHSVcolor
End Sub
Sub saturacionDown()
    'Asignar al +
    colorActual.S = colorActual.S - 0.2
    If colorActual.S < 0 Then
        colorActual.S = 0
    End If
    Call setHSVcolor
End Sub
Sub brilloUp()
    'Asignar al /
    colorActual.V = colorActual.V + 0.2
    If colorActual.V > 1 Then
        colorActual.V = 1
    End If
    Call setHSVcolor
End Sub
Sub brilloDown()
    'Asignar al *
    colorActual.V = colorActual.V - 0.2
    If colorActual.V < 0 Then
        colorActual.V = 0
    End If
    Call setHSVcolor
End Sub
'Para debuggear uso
'msgbox variable

Sub usarPaleta()
    'asignar al 0, una vez modo setear, 2 veces modo usar
    If guardarPaleta Then
        guardarPaleta = False
        If showMSG Then
            MsgBox "Cancelado (se guarda la paleta actual)"
        End If
        Call saveMem
    Else
        guardarPaleta = True
        If showMSG Then
            MsgBox "Modo guardar paleta:" & vbCrLf & "  1. Elija color." & vbCrLf & "  2. Elija memoria"
        End If
    End If
    
End Sub
Sub paleta1()
    'asignar al 7
    numPaleta = 0
    Call accederPaleta 'se guarda o aplica segun guardarPaleta este activa o no
End Sub
Sub paleta2()
    'asignar al 8
    numPaleta = 1
    Call accederPaleta 'se guarda o aplica segun guardarPaleta este activa o no
End Sub
Sub paleta3()
    'asignar al 9
    numPaleta = 2
    Call accederPaleta 'se guarda o aplica segun guardarPaleta este activa o no
End Sub
Sub siguientePaginaPaleta()
    'asignar al RePag
    If pagPaleta < 4 Then 'dim matriz = 3 - arracna en 0 = 2
        pagPaleta = pagPaleta + 1
    End If
    If showMSG Then
        MsgBox "pagina: " & pagPaleta + 1
    End If
End Sub
Sub anteriorPaginaPaleta()
    'asignar al AvPag
    If pagPaleta > 0 Then
        pagPaleta = pagPaleta - 1
    End If
    If showMSG Then
        MsgBox "pagina: " & pagPaleta + 1
    End If
End Sub

Sub codigo()
Attribute codigo.VB_ProcData.VB_Invoke_Func = "Normal.NewMacros.codigo"
' asignar a ctr + '+'
' inserta un codigo Ej, python
    Dim tamanioLetra As Integer, colorLetra As Long
    Dim txt As Shape
    Dim colorRGB As Long, color As color_struct
    Dim c As Long
    Dim left As Integer, top As Integer, width As Integer, height As Integer
    tamanioLetra = Selection.Font.Size
    colorLetra = Selection.Font.color
    'if textBox seleccionado then
    '   agrandarlo en anchura
    'else crear uno nuevo
    'al apretar enter, tabular y agrandar el cuadro de texto
    width = 400
    height = 60
    colorRGB = ActiveDocument.Background.Fill.ForeColor.rgb
    color.r = &HFF& And colorRGB
    color.g = (&HFF00& And colorRGB) \ 256
    color.b = (&HFF0000 And colorRGB) \ 65536
    
    color = rgb2hsv(color.r, color.g, color.b)
    color = hsv2rgb(color.H, color.S - 0.1, color.V + 0.1)
    
    'color.S = 1
    'color.V = 1
    
    left = Selection.Information(wdHorizontalPositionRelativeToPage)
    top = Selection.Information(wdVerticalPositionRelativeToPage)
    Set txt = ActiveDocument.Shapes.AddTextbox(msoTextOrientationHorizontal, left, top, width, height)
    With txt
        .TextFrame.MarginLeft = 5
        .TextFrame.MarginBottom = 2
        .TextFrame.MarginRight = 2
        .TextFrame.MarginTop = 2
        .TextFrame.AutoSize = True
        .Fill.ForeColor.rgb = rgb(color.r, color.g, color.b)
        .Line.Visible = msoFalse
    End With
    
    txt.Select

    Selection.Font.Size = tamanioLetra
    Selection.Font.color = colorLetra
    Selection.ParagraphFormat.SpaceAfter = False
    Selection.ParagraphFormat.SpaceBefore = False
    'Selection.ShapeRange.TextFrame.TextRange.Select


    
End Sub
Sub CargarPaletaColores()
Attribute CargarPaletaColores.VB_ProcData.VB_Invoke_Func = "Normal.NewMacros.asdfasdfasdf"
'Carga la paleta de colores de la aplicación template
'
Dim cantidadPaginas As Integer
    cantidadPaginas = 5
    showMSG = False
    Selection.MoveDown Unit:=wdLine, Count:=1
    For pag = 0 To cantidadPaginas - 1
        pagPaleta = pag 'Voy a cada pagina de la paleta
        Selection.MoveDown Unit:=wdLine, Count:=2
        Selection.EndKey Unit:=wdLine 'Voy al final de la oracion
        Application.Run MacroName:="Normal.NewMacros.getColor" 'Tomo el color
        Application.Run MacroName:="Normal.NewMacros.usarPaleta" 'Menu de guardado de paleta
        Application.Run MacroName:="Normal.NewMacros.paleta1"    'Guardo en posicion 1
        Selection.MoveDown Unit:=wdLine, Count:=1
        Application.Run MacroName:="Normal.NewMacros.getColor"
        Application.Run MacroName:="Normal.NewMacros.usarPaleta"
        Application.Run MacroName:="Normal.NewMacros.paleta2"
        Selection.MoveDown Unit:=wdLine, Count:=1
        Application.Run MacroName:="Normal.NewMacros.getColor"
        Application.Run MacroName:="Normal.NewMacros.usarPaleta"
        Application.Run MacroName:="Normal.NewMacros.paleta3"
        Application.Run MacroName:="Normal.NewMacros.siguientePaginaPaleta"
    Next pag
    pagPaleta = 0
    showMSG = True
End Sub
