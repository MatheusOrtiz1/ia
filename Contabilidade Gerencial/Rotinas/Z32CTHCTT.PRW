#INCLUDE "RWMAKE.CH"            
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function Z32CTHCTT()
    Local aArea   := GetArea()
    Local cFunBkp := FunName()
    Local oBrowse
    Local cTitulo := "Classe de Valor X Centro de Custo"
    Private CCADASTRO := "Classe de Valor X Centro de Custo"
    Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
                         {"Visualizar","AxVisual",0,2} ,;
                         {"Incluir","AxInclui",0,3 },;
                         {"Alterar","AxAltera",0,4} ,;
                         {"Facilitador","U_Z32CTCTH",0,4} ,;
                         {"Excluir","AxDeleta",0,5} }
     
    //Setando o nome da função, para a função customizada
    SetFunName("Z32CTHCTT")
     
    //Instânciando FWMBrowse, setando a tabela, a descrição e ativando a navegação
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("Z32")
    oBrowse:SetDescription(cTitulo)
    oBrowse:Activate()
     
    //Voltando o nome da função
    SetFunName(cFunBkp)
     
    RestArea(aArea)
Return Nil

User Function Z32CTCTH()
Local CQUERY1 := ""

if Input()

	CQUERY1 := " SELECT CTT_CUSTO, CTT_CLASSE "
	CQUERY1 += " FROM "+RETSQLNAME("CTT")+" CTT "
	CQUERY1 += " WHERE CTT.D_E_L_E_T_=''  "
	CQUERY1 += " AND CTT_FILIAL = '"+ xFilial("CTT")+"'  "
	CQUERY1 += " AND CTT_CUSTO >= '"+MV_PAR02+"' AND  CTT_CUSTO <= '"+MV_PAR03+"' "
    IF SELECT("TRB2")!=0
		TRB2->(DBCLOSEAREA())
	ENDIF

	TCQUERY CQUERY1 NEW ALIAS "TRB2" 
	DBSELECTAREA("TRB2")
	DBGOTOP()

	WHILE !TRB2->(eof())
		DBSELECTAREA("Z32") 
		DBSETORDER(1)
		IF DBSEEK(xFilial("Z32")+MV_PAR01+TRB2->CTT_CUSTO)
            ALERT("REGISTRO JA CADASTRADO, CLASSE DE VALOR: "+MV_PAR01 +" - C.CUSTO: "+TRB2->CTT_CUSTO)
        else	
            IF TRB2->CTT_CLASSE == '2'
                IF RECLOCK("Z32",.T.)       
                    Z32->Z32_FILIAL := xFilial("Z32")
                    Z32->Z32_CLVL := MV_PAR01
                    Z32->Z32_CCUSTO := TRB2->CTT_CUSTO
                    MSUNLOCK()	
                ENDIF
			ENDIF
		EndIf     
     TRB2->(DBSKIP()) 
	ENDDO
	TRB2->(DBCLOSEAREA())

ENDIF


Return()


Static Function Input()
//Local lret     := .F.
Local aPergs   := {}
Local cTitle     := "Facilitador Amarração"
local aRet       := {}
local bOk        := {|| .t.}
local aButtons   := {}
local lCentered  := .t.
local nPosX      := nil
local nPosY      := nil
local oDlgWizard := nil
Local cProgram   := "Z32CTHCTT"
local cLoad      := allTrim(cProgram) + ".pbx"
local lCanSave   := .t.
local lUserSave  := .t.
local okPress    := .f.
 
aAdd(aPergs, {1, "Classe de Valor ",         Space(12),  "@!", "ExistCpo('CTH',MV_PAR01,1)", "CTH",     "", 70, .T.})
aAdd(aPergs, {1, "C.Custo de ",    Space(20),  "@!", "", "CTT",     "", 80, .T.})
aAdd(aPergs, {1, "C.Custo Até ",   Space(20),  "@!", "", "CTT",     "", 80, .T.})

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
