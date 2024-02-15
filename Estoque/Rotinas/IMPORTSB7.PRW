
#include "totvs.ch"
#include "protheus.ch"
 
User Function SB7INVT()
    Private cArqx    := ""
    Private oProcess_
    Private lRenomear:= .F.

    B2XXXX()

    IF !INPUT()
        Return()
    ENDIF

    cArqx    := Alltrim(MV_PAR01)

    if Empty(cArqx)
        MsgStop("Informe o nome do arquivo!!!","Erro")
            IF MSGYESNO( "Deseja prosseguir?","Arquivo vazio " )
                B2XXXX()
            ENDIF
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
    nPosTipo 	:= aScan(aCampos,{ |x| ALLTRIM(x) == "Tipo" })          //B9_DOC
    nPosQtde   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "Qtde.1a.U.M." })  //B9_QUANT
    
    aCampos[nPosCod]    := "B7_COD"
    aCampos[nPosLoc]    := "B7_LOCAL"
    aCampos[nPosQtde]   := "B7_QUANT"
    aCampos[nPosTipo]   := "B7_TIPO"

    IF !(LEN(aCampos) >= 4)
        MSGINFO( "Arquivo deve conter no mínimo 4 colunas", "Estrutura do Arquivo" )
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
        If !dbSeek(xFilial("SB7")+"20231031"+aDados[i,nPosCod]+aDados[i,nPosLoc])
            oProcess:SetRegua2(len(aCampos))
           
            oProcess:IncRegua2('Processando linha: ' + ALLTRIM(CVALTOCHAR(i)))

            IF RECLOCK("SB7",.T.)
                SB7->B7_FILIAL      := xFilial("SB7")
                SB7->B7_DATA        := STOD("20231031")
                SB7->B7_COD         := aDados[i,nPosCod]
                SB7->B7_LOCAL       := aDados[i,nPosLoc]
                SB7->B7_TIPO        := aDados[i,nPosTipo]
                SB7->B7_DOC         := "I82311023"
                SB7->B7_QUANT       := val(aDados[i,nPosQtde])
                SB7->B7_STATUS      := '1'
                SB7->B7_ORIGEM      := 'SB7INVT'
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
    

    B2XXXX()

    If Len(aErro) > 0
        MostraLog()
    Else
        ApMsgInfo("Importação de Produtos efetuada com sucesso!","SUCESSO")
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

aAdd(aPergs, {1, "Selecione o Arquivo ? ",     cArquivo, "",             ".F.",        "DIR",    ".T.", 120, .F.})
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

STATIC Function B2XXXX()

IF MSGYESNO( "Deseja inventariar produtos com saldo maior que zero e local menor que 80?", "Gera SB7" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega informações da tela	(cAlias)		                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSql := " SELECT B2_FILIAL,B2_COD,B2_LOCAL, SUM(B2_QATU) AS B2_QATU " 
	cSql += " FROM "+RetSqlName("SB2") + " SB2"
	cSql += " WHERE SB2.B2_FILIAL = '"+xFilial("SB2")+"' AND SB2.B2_LOCAL < Z0' AND SB2.B2_QATU > 0 AND SB2.D_E_L_E_T_='' "
	cSql += " GROUP BY B2_COD,B2_LOCAL,B2_FILIAL"
	cSql += " ORDER BY B2_COD"
	IF SELECT("TMP75")!=0
		TMP75->(DBCLOSEAREA())
	ENDIF
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),"TMP75",.F.,.T.)
	DbSelectArea("TMP75")
	DbGoTop()
	
	While TMP75->(!Eof())

        dbSelectArea("SB7")
        dbSetOrder(1)

        //Neste exemplo iremos incluir registros, portanto iremos validar se o mesmo não existe na tabela de clientes
        If !dbSeek(xFilial("SB7")+DTOS(DDATABASE)+TMP75->B2_COD+TMP75->B2_LOCAL)

            IF RECLOCK("SB7",.T.)
                SB7->B7_FILIAL      := xFilial("SB7")
                SB7->B7_DATA        := DDATABASE
                SB7->B7_COD         := TMP75->B2_COD
                SB7->B7_LOCAL       := TMP75->B2_LOCAL
                SB7->B7_TIPO        := POSICIONE("SB1",1,xFilial("SB1")+TMP75->B2_COD,"B1_TIPO")
                SB7->B7_DOC         := "II"+DTOS(DATE())
                SB7->B7_QUANT       := 0
                SB7->B7_STATUS      := '1'
                SB7->B7_ORIGEM      := 'IMPORTSB7'
            MSUNLOCK()                
            ENDIF

        EndIf
    TMP75->(DBSKIP())
    ENDDO

ENDIF 
RETURN
