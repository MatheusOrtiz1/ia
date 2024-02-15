
#include "totvs.ch"
#include "protheus.ch"
 
User Function IMPMTA270()
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
    nPosCod    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "Produto" })       //B7_COD
    nPosLoc   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "Armazem" })       //B7_LOCAL
    nPosdoc   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "Documento" })     //B7_DOC
    nPosQtde   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "Quantidade" })    //B7_QUANT
    
    aCampos[nPosCod]    := "B7_COD"
    aCampos[nPosLoc]    := "B7_LOCAL"
    aCampos[nPosdoc]    := "B7_DOC"
    aCampos[nPosQtde]   := "B7_QUANT"

    IF !(LEN(aCampos) >= 7)
        MSGINFO( "Arquivo deve conter no mínimo 7 colunas", "Estrutura do Arquivo" )
        RETURN()
    ENDIF

    oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros
    
    For i:=1 to Len(aDados)
    
        oProcess:IncRegua1("Importando Inventário..."+DTOC(DDATABASE)+" - "+aDados[i,nPosCod]+" - "+aDados[i,nPosLoc])
        
        aLista := {}
    
        dbSelectArea("SB7")
        dbSetOrder(1)
        dbGoTop()

        //Neste exemplo iremos incluir registros, portanto iremos validar se o mesmo não existe na tabela de clientes
        If !dbSeek(xFilial("SB7")+DTOS(DDATABASE)+aDados[i,nPosCod]+aDados[i,nPosLoc])
            oProcess:SetRegua2(len(aCampos))
           
                oProcess:IncRegua2('Processando linha: ' + ALLTRIM(CVALTOCHAR(i)))
                                  
            aLista := {{"B7_FILIAL"         , xFilial("SB7")             ,Nil},;
                        {"B7_COD"           ,aDados[i,nPosCod]           ,Nil},;
                        {"B7_TIPO"          ,POSICIONE("SB1",1,xFilial("SB1")+aDados[i,nPosCod],"B1_UM")           ,Nil},;
                        {"B7_LOCAL"         ,aDados[i,nPosLoc]           ,Nil},;
                        {"B7_DOC"           ,aDados[i,nPosdoc]           ,Nil},;
                        {"B7_QUANT"         ,VAL(aDados[i,nPosQtde])     ,Nil},;
                        {"B7_DATA"          ,DDATABASE                   ,Nil},;
                        {"B7_ORIGEM"        ,"IMPMTA270"                 ,Nil} }           


                lMsErroAuto := .F.
                //Utilizar o MsExecAuto para incluir registros na tabela de Inventario
                MSExecAuto({|x,y| mata030(x,y)},aLista,3)
                //Caso encontre erro exibir na tela
                If lMsErroAuto

                    cDiretorio := "C:\TEMP\"
                    cArqx   := "log_mata270_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-')
    
                    MostraErro(_cDiretorio, _cArquivo)
                    
                    GravaErro(aDados[i,nPosCod],aDados[i,nPosLoc],aDados[i,nPosdoc],NIL)
                    //DisarmTransaction()

                    IF MSGYESNO("Abortar operação?", "Interromper o processo?")
                        Return()
                    ENDIF
                EndIf

            
        Else //Caso o registro exista, gravar o log
            GravaErro(aDados[i,nPosCod],aDados[i,nPosLoc],aDados[i,nPosdoc],"O registro já está cadastrado!")
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

Return

Static Function GravaErro(cCod,cLocal,cDoc,cMsg)

    Local cFile := _cDiretorio+_cArquivo
    Local cLine := ""

    DEFAULT cMsg  := NIL

    If cMsg == NIL
        Begin Sequence
            IF !( lOk := File( cFile ) )
                Break
            EndIF
    
            FT_FUSE(cFile)
            FT_FGOTOP()
    
            While !FT_FEOF()
        
                cLine += FT_FREADLN() + CHR(13)+CHR(10)
        
                FT_FSKIP()
            End While
    
            FT_FUSE()
        End Sequence
    
        cMsg := cLine
    EndIf

    AADD(aErro,{cCod,cLocal,cDoc,cMsg})

Return

Static Function MostraLog()

    Local oDlg
    Local oFont
    Local cMemo := ""

    DEFINE FONT oFont NAME "Courier New" SIZE 5,0

    DEFINE MSDIALOG oDlg TITLE "Importação Invantario" From 3,0 to 400,417 PIXEL

    aCabec := {"Código","Loja","Nome"}
    cCabec := "{aErro[oBrw:nAT][1],aErro[oBrw:nAT][2],aErro[oBrw:nAT][3]}"
    bCabec := &amp;( "{ || " + cCabec + " }" )

    oBrw := TWBrowse():New( 005,005,200,090,,aCabec,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
    oBrw:SetArray(aErro)
    oBrw:bChange    := { || cMemo := aErro[oBrw:nAT][4], oMemo:Refresh()}
    oBrw:bLDblClick := { || cMemo := aErro[oBrw:nAT][4], oMemo:Refresh()}
    oBrw:bLine := bCabec

    @ 100,005 GET oMemo VAR cMemo MEMO SIZE 200,080 OF oDlg PIXEL

    oMemo:bRClicked := {||AllwaysTrue()}
    oMemo:lReadOnly := .T.
    oMemo:oFont := oFont

    //oImprimir :=tButton():New(185,120,'Imprimir' ,oDlg,{|| fImprimeLog() },40,12,,,,.T.)
    oSair     :=tButton():New(185,165,'Sair'     ,oDlg,{|| ::End() },40,12,,,,.T.)

    ACTIVATE MSDIALOG oDlg CENTERED

Return


Static Function fImprimeLog()

    Local oReport

    If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
        oReport := ReportDef()
        oReport:PrintDialog()
    EndIf

Return

Static Function ReportDef()

    Local oReport
    Local oSection

    oReport := TReport():New(FUNNAME(),"Importação Cadastro de Fornecedores",,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de erros encontrados durante o processo de importação dos dados.")
    oReport:SetLandscape()

    oSection := TRSection():New(oReport,,{})

    TRCell():New(oSection,"CODIGO"  ,,"Código")
    TRCell():New(oSection,"LOJA"    ,,"Loja")
    TRCell():New(oSection,"NOME"    ,,"Nome")
    TRCell():New(oSection,"DESCRI"  ,,"Descrição do Erro")

Return oReport

Static Function PrintReport(oReport)
    Local nCurrentLine,i
    Local oSection := oReport:Section(1)

    oReport:SetMeter(Len(aErro))

    oSection:Init()

    For i:=1 to Len(aErro)
    
        If oReport:Cancel()
            Exit
        EndIf
    
        oReport:IncMeter()
    
        oSection:Cell("CODIGO"):SetValue(aErro[i,1])
        oSection:Cell("CODIGO"):SetSize(20)
        oSection:Cell("LOJA"):SetValue(aErro[i,2])
        oSection:Cell("LOJA"):SetSize(20)
        oSection:Cell("NOME"):SetValue(aErro[i,3])
        oSection:Cell("NOME"):SetSize(50)
        oSection:Cell("DESCRI"):SetValue(aErro[i,4])
        oSection:Cell("DESCRI"):SetSize(200)
    
        nTamLin := 200
        nTab := 3
        lWrap := .T.
    
        lPrim := .T.
    
        cObsMemo := aErro[i,4]
        nLines   := MLCOUNT(cObsMemo, nTamLin, nTab, lWrap)
    
        For nCurrentLine := 1 to nLines
            If lPrim
                oSection:Cell("DESCRI"):SetValue(MEMOLINE(cObsMemo, nTamLin, nCurrentLine, nTab, lWrap))
                oSection:Cell("DESCRI"):SetSize(300)
                oSection:PrintLine()
                lPrim := .F.
            Else
                oSection:Cell("CODIGO"):SetValue("")
                oSection:Cell("LOJA"):SetValue("")
                oSection:Cell("NOME"):SetValue("")
                oSection:Cell("DESCRI"):SetValue(MEMOLINE(cObsMemo, nTamLin, nCurrentLine, nTab, lWrap))
                oSection:Cell("DESCRI"):SetSize(300)
                oSection:PrintLine()
            EndIf
        Next i
    
        oReport:SkipLine()
    Next i

    oSection:Finish()

Return

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

