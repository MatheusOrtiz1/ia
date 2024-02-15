#include "totvs.ch"
#include "protheus.ch"

User Function PRODIMPOR()
    Local aArea  	:= GetArea()
    Local cTitulo	:= "Importação Cadastro de Produto"
    Local nOpcao 	:= 0
    Local aButtons 	:= {}
    Local aSays    	:= {}
    Local cPerg		:= "PRODIMPOR"
    Private cArquivo:= ""
    Private oProcess
    Private lRenomear:= .F.
    Private lMsErroAuto := .F.
    
    INPUT()

    AADD(aSays,OemToAnsi("Rotina para Importação de arquivo texto para tabela SB1"))
    AADD(aSays,"")
    AADD(aSays,OemToAnsi("Clique no botão PARAM para informar os parametros que deverão ser considerados."))
    AADD(aSays,"")
    AADD(aSays,OemToAnsi("Após isso, clique no botão OK."))

    AADD(aButtons, { 1,.T.,{|o| nOpcao:= 1,o:oWnd:End()} } )
    AADD(aButtons, { 2,.T.,{|o| nOpcao:= 2,o:oWnd:End()} } )
    AADD(aButtons, { 5,.T.,{| | pergunte(cPerg,.T.)  } } )

    FormBatch( cTitulo, aSays, aButtons,,200,530 )

    if nOpcao = 1
        cArquivo:= Alltrim(MV_PAR01)

        if Empty(cArquivo)
            MsgStop("Informe o nome do arquivo!!!","Erro")
            return
        Endif

        oProcess := MsNewProcess():New( { || Importa() } , "Importação de registros " , "Aguarde..." , .F. )
        oProcess:Activate()
        
    EndIf

    RestArea(aArea)

Return

Static Function Importa()
    Local cArqProc   := cArquivo+".processado"
    Local cLinha     := ""
    Local cRetCod     := ""
    Local lPrim      := .T.
    Local aCampos    := {}
    Local aDados     := {}
    Local aProduto   := {}
    Local nCont		 := 1
    Local nPosCod    := ""
    Local nPosDesc   := ""
    Local nPosTipo   := ""
    Local nPosCodMun := ""
    Local nLocPad    := ""
    Local nFamilia 	 := ""
    Local nFantasm 	 := ""
    Local nForaest 	 := ""
    Local nOrigem 	 := ""
    Local nPosIpi 	 := ""
    Local nImpZfr 	 := ""
    Local nIrrf 	 := ""
    Local nInss 	 := ""
    Local nPis 	     := ""
    Local nCofins 	 := ""
    Local nCsll 	 := ""
    Local nEmin 	 := ""
    Local nEstSeg 	 := ""
    Local nGarant 	 := ""
    LOCAL I
    Private aErro 	 := {}
    Private cFileErro 	 := ""
    Private nMaxGrup := TamSx3("B1_GRUPO")[1]
    Private nMaxLocP := TamSx3("B1_LOCPAD")[1]
    Private nMaxNIpi := 8

    If !File(cArquivo)
        MsgStop("O arquivo " + cArquivo + " não foi encontrado. A importação será abortada!","[AEST904] - ATENCAO")
        Return
    EndIf

    FT_FUSE(cArquivo) //Abre o arquivo texto
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
    nPosCod    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_COD" })
    nGrupo   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_GRUPO" })
    nPosDesc   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_DESC" })
    nPosTipo   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_TIPO" })
    nPosCodMun 	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_UM" })
    nLocPad 	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_LOCPAD" })
    nFamilia 	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_FAMILIA" })
    nFantasm 	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_FANTASM" })
    nForaest	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_FORAEST" })
    nOrigem 	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_ORIGEM" })
    nPosIpi 	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_POSIPI" })
    nImpZfr 	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_IMPZFRC" })
    nIrrf    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_IRRF" })
    nInss    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_INSS" })
    nPis    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_PIS" })
    nCofins 	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_COFINS" })
    nCsll   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_CSLL" })
    nEmin   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_EMIN" })
    nEstSeg 	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_ESTSEG" })
    nGarant 	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_GARANT" })
    
    oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros
    
    IF nPosCod > 0 .AND. nPosDesc > 0
        For i:=1 to Len(aDados)
        
            oProcess:IncRegua1(aDados[i,nPosCod]+" - "+aDados[i,nPosDesc])
            CONOUT(aDados[i,nPosCod]+" - "+aDados[i,nPosDesc])
            aProduto := {}
        
            dbselectarea("SB1")
            dbsetorder(1)
            dbseek(xfilial()+rtrim(aDados[i,nGrupo])+"999999",.t.)
            dbskip(-1)
            if bof() .or. substr(SB1->B1_COD,1,4) <> rtrim(aDados[i,nGrupo])
                cRetCod := rtrim(aDados[i,nGrupo]) + "000001"
            else
                cRetCod := rtrim(aDados[i,nGrupo]) + strzero(val(substr(SB1->B1_COD,5,6)) + 1,6)
            endif

            //Iremos incluir registros, portanto iremos validar se o mesmo não existe na tabela de pRODUTOS
            If !dbSeek(xFilial("SB1")+aDados[i,nPosCod])
                oProcess:SetRegua2(len(aCampos))
            
                    M->B1_GRUPO := STRZERO(VAL(aDados[i,nGrupo]),nMaxGrup)

                    aProduto := {{"B1_COD"    ,cRetCod                   ,Nil},;
                                {"B1_GRUPO"   ,STRZERO(VAL(aDados[i,nGrupo]),nMaxGrup)      ,Nil},;
                                {"B1_DESC"    ,aDados[i,nPosDesc]        ,Nil},;
                                {"B1_TIPO"    ,aDados[i,nPosTipo]        ,Nil},; 
                                {"B1_UM"      ,ALLTRIM(aDados[i,nPosCodMun])      ,Nil},; 
                                {"B1_LOCPAD"  ,STRZERO(VAL(aDados[i,nLocPad]),nMaxLocP)         ,Nil},; 
                                {"B1_FAMILIA" ,aDados[i,nFamilia]        ,Nil},;
                                {"B1_FANTASM" ,aDados[i,nFantasm]        ,Nil},; 
                                {"B1_FORAEST" ,aDados[i,nForaest]        ,Nil},; 
                                {"B1_ORIGEM"  ,aDados[i,nOrigem]         ,Nil},; 
                                {"B1_POSIPI"  ,STRZERO(VAL(aDados[i,nPosIpi]),nMaxNIpi)         ,Nil},; 
                                {"B1_IMPZFRC" ,aDados[i,nImpZfr]         ,Nil},; 
                                {"B1_IRRF"    ,aDados[i,nIrrf]           ,Nil},; 
                                {"B1_INSS"    ,aDados[i,nInss]           ,Nil},; 
                                {"B1_PIS"     ,aDados[i,nPis]            ,Nil},; 
                                {"B1_COFINS"  ,aDados[i,nCofins]         ,Nil},; 
                                {"B1_CSLL"    ,aDados[i,nCsll]           ,Nil},; 
                                {"B1_EMIN"    ,VAL(aDados[i,nEmin])      ,Nil},; 
                                {"B1_ESTSEG"  ,VAL(aDados[i,nEstSeg])    ,Nil},; 
                                {"B1_GARANT"  ,aDados[i,nGarant]         ,Nil}}


                lMsErroAuto := .F.
                //Utilizar o MsExecAuto para incluir registros na tabela de clientes, utilizando a opção 3
                MSExecAuto({|x,y| Mata010(x,y)},aProduto,3)
                //Caso encontre erro exibir na tela
                If lMsErroAuto
                    //MostraErro()
                    cFileErro := NomeAutoLog()
                    MostraErro("C:\TEMP\",cFileErro)
                    GravaErro(aDados[i,nPosCod],aDados[i,nPosDesc],aDados[i,nGrupo],NIL)
                    DisarmTransaction()
                EndIf

            Else //Caso o registro exista, gravar o log
                GravaErro(aDados[i,nPosCod],aDados[i,nPosDesc],aDados[i,nGrupo],"O registro já está cadastrado!")
            EndIf
        Next i

            fRename(Upper(cArquivo), cArqProc)
        
        If Len(aErro) > 0
            MostraLog()
        Else
            ApMsgInfo("Importação de clientes efetuada com sucesso!","SUCESSO")
        EndIf
    ELSE
        ApMsgInfo("Não foi possível ler o produto","IMPORTA CSV - COLUNAS NOME DOS CAMPOS")
    ENDIF

Return

Static Function GravaErro(cCod,cLoja,cNome,cMsg)

    Local cFile := cFileErro
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

    AADD(aErro,{cCod,cLoja,cNome,cMsg})

Return

Static Function MostraLog()

    Local oDlg
    Local oFont
    Local cMemo := ""

    DEFINE FONT oFont NAME "Courier New" SIZE 5,0

    DEFINE MSDIALOG oDlg TITLE "Importação Cadastros" From 3,0 to 400,417 PIXEL

    aCabec := {"Código","Grupo","Descrição","Tipo","Unidade de Medida","Local Padrão",;
               "Familia","Fantasma","Descrição do Erro","Origem","NCM","Zona Franca de Manaus",;
               "IRRF","INSS","PIS","COFINS","Elemina Residuo","Estoque Mínimo","Garantia"}
    cCabec := "{aErro[oBrw:nAT][1],aErro[oBrw:nAT][2],aErro[oBrw:nAT][3]}"
    //bCabec := ( "{ || " + cCabec + " }" )

    oBrw := TWBrowse():New( 005,005,200,090,,aCabec,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
    oBrw:SetArray(aErro)
    oBrw:bChange    := { || cMemo := aErro[oBrw:nAT][4], oMemo:Refresh()}
    oBrw:bLDblClick := { || cMemo := aErro[oBrw:nAT][4], oMemo:Refresh()}
    oBrw:bLine := cCabec

    @ 100,005 GET oMemo VAR cMemo MEMO SIZE 200,080 OF oDlg PIXEL

    oMemo:bRClicked := {||AllwaysTrue()}
    oMemo:lReadOnly := .T.
    oMemo:oFont := oFont

    oImprimir :=tButton():New(185,120,'Imprimir' ,oDlg,{|| fImprimeLog() },40,12,,,,.T.)
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

    oReport := TReport():New(FUNNAME(),"Importação Cadastro de Produtos",,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de erros encontrados durante o processo de importação dos dados.")
    oReport:SetLandscape()

    oSection := TRSection():New(oReport,,{})

    TRCell():New(oSection,"B1_COD"          ,,"Código")
    TRCell():New(oSection,"B1_GRUPO"        ,,"Grupo")
    TRCell():New(oSection,"B1_DESC"         ,,"Descrição")
    TRCell():New(oSection,"B1_TIPO"         ,,"Tipo")
    TRCell():New(oSection,"B1_UM"           ,,"Unidade de Medida")
    TRCell():New(oSection,"B1_LOCPAD"       ,,"Local Padrão")
    TRCell():New(oSection,"B1_FAMILIA"      ,,"Familia")
    TRCell():New(oSection,"B1_FANTASM"      ,,"Fantasma")
    TRCell():New(oSection,"B1_FORAEST"      ,,"Descrição do Erro")
    TRCell():New(oSection,"B1_ORIGEM"       ,,"Origem")
    TRCell():New(oSection,"B1_POSIPI"       ,,"NCM")
    TRCell():New(oSection,"B1_IMPZFRC"      ,,"Zona Franca de Manaus")
    TRCell():New(oSection,"B1_IRRF"         ,,"IRRF")
    TRCell():New(oSection,"B1_INSS"         ,,"INSS")
    TRCell():New(oSection,"B1_PIS"          ,,"PIS")
    TRCell():New(oSection,"B1_COFINS"       ,,"COFINS")
    TRCell():New(oSection,"B1_CSLL"         ,,"CSLL")
    TRCell():New(oSection,"B1_EMIN"         ,,"Elemina Residuo")
    TRCell():New(oSection,"B1_ESTSEG"       ,,"Estoque Mínimo")
    TRCell():New(oSection,"B1_GARANT"       ,,"Garantia")

Return oReport

Static Function PrintReport(oReport)

    Local oSection := oReport:Section(1)
    Local nCurrentLine,i

    oReport:SetMeter(Len(aErro))

    oSection:Init()

    For i:=1 to Len(aErro)
    
        If oReport:Cancel()
            Exit
        EndIf
    
        oReport:IncMeter()
    
        oSection:Cell("B1_COD"):SetValue(aErro[i,1])
        oSection:Cell("B1_COD"):SetSize(20)
        oSection:Cell("B1_DESC"):SetValue(aErro[i,2])
        oSection:Cell("B1_DESC"):SetSize(20)
        oSection:Cell("B1_UM"):SetValue(aErro[i,3])
        oSection:Cell("B1_UM"):SetSize(50)
        oSection:Cell("ERRO"):SetValue(aErro[i,4])
        oSection:Cell("ERRO"):SetSize(200)
      
    
        nTamLin := 200
        nTab := 3
        lWrap := .T.
    
        lPrim := .T.
    
        cObsMemo := aErro[i,4]
        nLines   := MLCOUNT(cObsMemo, nTamLin, nTab, lWrap)
    
        For nCurrentLine := 1 to nLines
            If lPrim
                oSection:Cell("B1_DESC"):SetValue(MEMOLINE(cObsMemo, nTamLin, nCurrentLine, nTab, lWrap))
                oSection:Cell("B1_DESC"):SetSize(300)
                oSection:PrintLine()
                lPrim := .F.
            Else
                oSection:Cell("B1_COD"):SetValue("")
                oSection:Cell("B1_GRUPO"):SetValue("")
                oSection:Cell("B1_DESC"):SetValue("")
                oSection:Cell("B1_TIPO"):SetValue(MEMOLINE(cObsMemo, nTamLin, nCurrentLine, nTab, lWrap))
                oSection:Cell("B1_UM"):SetSize(10)
                oSection:Cell("B1_LOCPAD"):SetSize(10)
                oSection:Cell("B1_FAMILIA"):SetSize(10)
                oSection:Cell("B1_FANTASM"):SetSize(10)
                oSection:Cell("B1_FORAEST"):SetSize(10)
                oSection:Cell("B1_ORIGEM"):SetSize(10)
                oSection:Cell("B1_POSIPI"):SetSize(10)
                oSection:Cell("B1_IMPZFRC"):SetSize(10)
                oSection:Cell("B1_IRRF"):SetSize(10)
                oSection:Cell("B1_INSS"):SetSize(10)
                oSection:Cell("B1_PIS"):SetSize(10)
                oSection:Cell("B1_COFINS"):SetSize(10)
                oSection:Cell("B1_CSLL"):SetSize(10)
                oSection:Cell("B1_EMIN"):SetSize(10)
                oSection:Cell("B1_ESTSEG"):SetSize(10)
                oSection:Cell("B1_GARANT"):SetSize(10)
                oSection:PrintLine()
            EndIf
        Next i
    
        oReport:SkipLine()
    Next i

    oSection:Finish()

Return

Static Function Input()
Local aPergs   := {}
Local cTitle     := "Parametros de importação cadastro de produto "
local aRet       := {}
local bOk        := {|| .t.}
local aButtons   := {}
local lCentered  := .t.
local nPosX      := nil
local nPosY      := nil
local oDlgWizard := nil
Local cProgram   := "IMPPRODUTO"
local cLoad      := allTrim(cProgram) + ".pbx"
local lCanSave   := .t.
local lUserSave  := .t.
local okPress    := .f.
 
aAdd(aPergs, {1, "Arquivo ? " ,     Space(100)       ,  "@!", "", "DIR",     "", 80, .T.})

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

Return(.T.)
