
#include "totvs.ch"
#include "protheus.ch"
 
User Function IMPORTSB9()
    Private cArqx    := ""
    Private oProcess_
    Private lRenomear:= .F.

    
    IF !INPUT()
        Return()
    ENDIF

    cArqx    := Alltrim(MV_PAR01)

    if Empty(cArqx)
        MsgStop("Informe o nome do arquivo!!!","Erro")
        return
    Endif

    oProcess := MsNewProcess():New( { || Importa() } , "Importação de registros " , "Aguarde..." , .F. )
    oProcess:Activate()
    
Return


Static Function Importa()
    Local aArea  	:= GetArea()
    Local i
    Local cArqProc   := cArqx+".processado"
    Local cLinha     := ""
    Local lPrim      := .T.
    Local aCampos    := {}
    Local aDados     := {}
    Local aLista     := {}
    Local nCont		 := 1
    Local nPosCod    := 0
    Private _cDiretorio := ""
    Private _cArquivo   := ""
    Private aErro 	 := {}
    Private lMsErroAuto := .F.

    FT_FUSE(cArqx) //Abre o arquivo texto
    oProcess:SetRegua1(FT_FLASTREC()) //Preenche a regua com a quantidade de registros encontrados
    FT_FGOTOP() //coloca o arquivo no topo
    While !FT_FEOF()
        nCont++
        oProcess:IncRegua1('Validando Linha: ' + Alltrim(Str(nCont)))
        
        cLinha := FT_FREADLN()
        cLinha := ALLTRIM(cLinha)
    
        If lPrim //considerando que a primeira linha são os campos do cadastros, reservar numa variavel
            aCampos := Separa(cLinha,";",.T.)
            lPrim := .F.
        Else// gravar em outra variavel os registros
            AADD(aDados,Separa(cLinha,";",.T.))
        EndIf
    
        FT_FSKIP()
    EndDo

    FT_FUSE()
    
    //utilizaremos a aScan para localizar a posição dos campos na variavel que armazenará o nome dos campos
    nPosCod    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "Produto" })       //B9_COD
    nPosLoc   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "Armazem" })       //B9_LOCAL
    nPosVlUnit 	:= aScan(aCampos,{ |x| ALLTRIM(x) == "Valor unit" })     //B9_DOC
    nPosQtde   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "Qtde.1a.U.M." })    //B9_QUANT
    
    aCampos[nPosCod]    := "B9_COD"
    aCampos[nPosLoc]    := "B9_LOCAL"
    aCampos[nPosQtde]   := "B9_QINI"
    aCampos[nPosVlUnit] := "B9_VINI1"

    IF !(LEN(aCampos) >= 4)
        MSGINFO( "Arquivo deve conter no mínimo 4 colunas", "Estrutura do Arquivo" )
        RETURN()
    ENDIF

    oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros
    
    For i:=1 to Len(aDados)
    
        oProcess:IncRegua1("Importando Inventário..."+DTOC(DDATABASE)+" - "+aDados[i,nPosCod]+" - "+aDados[i,nPosLoc])
        
        aLista := {}
    
        dbSelectArea("SB9")
        dbSetOrder(1)
        dbGoTop()

        //Neste exemplo iremos incluir registros, portanto iremos validar se o mesmo não existe na tabela de clientes
        If !dbSeek(xFilial("SB9")+aDados[i,nPosCod]+aDados[i,nPosLoc]+"20231031")
            oProcess:SetRegua2(len(aCampos))
           
            oProcess:IncRegua2('Processando linha: ' + ALLTRIM(CVALTOCHAR(i)))

            IF RECLOCK("SB9",.T.)
                SB9->B9_FILIAL      := xFilial("SB9")
                SB9->B9_DATA        := STOD("20231031")
                SB9->B9_COD         := aDados[i,nPosCod]
                SB9->B9_LOCAL       := aDados[i,nPosLoc]
                SB9->B9_QINI        := val(aDados[i,nPosQtde])
                SB9->B9_CM1         := val(aDados[i,nPosVlUnit])
            MSUNLOCK()                
            ENDIF

        EndIf

    Next i

    IF(MV_PAR02=="S")
        If File(cArqProc)
            fErase(cArqProc)
        Endif
        fRename(Upper(cArqx), cArqProc)
    Endif	
    
    If Len(aErro) > 0
        MostraLog()
    Else
        ApMsgInfo("Importação de clientes efetuada com sucesso!","SUCESSO")
    EndIf
RestArea(aArea)


Static Function Input()
Local lret       := .T.
Local aPergs     := {}
Local cTitle     := "IMPORTAÇÃO INVENTARIO"
local aRet       := {}
local bOk        := {|| .t.}
local aButtons   := {}
local lCentered  := .t.
local nPosX      := nil
local nPosY      := nil
local oDlgWizard := nil
Local cProgram   := "IMPMTA270"
local cLoad      := allTrim(cProgram) + ".pbx"
local lCanSave   := .t.
local lUserSave  := .t.
local okPress    := .f.
Local cArquivo   := Space(120)
Local nVinc      := "N"

aAdd(aPergs, {1, "Selecione o Arquivo ? ",     cArquivo, "",             ".T.",        "DIR",    ".T.", 120, .T.})
aAdd(aPergs, {2, "Renomear o Arquivo  ?",      nVinc, {"S=Sim (Automaticamente)", "N=Não"},                                       090, ".T.", .F.})


okPress := paramBox(aPergs ;		//Array: 	Array contendo as perguntas
, cTitle ;		//Caracter:	Título da tela
, aRet ;		//Array:	Array contendo as respostas
, bOk ;			//Array:	Code block para validar o botão Ok
, aButtons; 	//Array:	Array contendo definições dos botões opcionais, além dos botões de Ok e Cancel
, lCentered ; 	//Lógico:	Indica se será centralizada a janela
, nPosX ;		//Numérico:	Se não centralizar janela, coordenada X da janela
, nPosY ;		//Numérico:	Se não centralizar janela, coordenada Y da janela
, oDlgWizard ;	//Objeto: 	Objeto referente à janela ativa
, cLoad ;		//Caracter:	Nome arquivo para gravar respostas
, lCanSave ; 	//Lógico:	Indica se pode salvar o arquivo com respostas
, lUserSave)	//Lógico:	Indica se salva nome do usuario no arquivo

if !okPress
    return(.F.)
endIf

Return(lret)

