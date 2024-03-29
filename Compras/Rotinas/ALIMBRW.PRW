#include "protheus.ch"

User Function ALIMBRW()

Local cAlias := "ALI"
Local aCores := {}   
Local cGrpFiltro:="000022"
Local cFiltra := "( ALI_FILIAL = '" + xFilial("ALI") + "' .AND. ALI_USER == '" + cGrpFiltro + "' .AND. ALI_STATUS $ '01/02/03' ) .OR. ( ALI_FILIAL = '" + xFilial("ALI") + "' .AND. ALI_STATUS $ '04/05' .AND. !EMPTY(ALI_HISTOR) )"
//Local cFiltra := "ALI_FILIAL = '" + xFilial("ALI") + "' .AND. ALI_USER == '" + cGrpFiltro + "'"

// Vari�veis para MBrowse com filtro
Private aIndexALI  := {}
Private bFiltraBrw := { || FilBrowse(cAlias, @aIndexALI, cFiltra) }

// Vari�veis da MBrowse - obrigat�rias
Private cCadastro  := "Acompanhamento de Conting�ncias"
Private aRotina    := {}

AADD(aRotina,{"Pesquisar"      ,"PesqBrw"   ,0,1})
AADD(aRotina,{"Visualizar"     ,"AxVisual"  ,0,2})  
AADD(aRotina,{"Legenda"        ,"U_Leadleg"  ,0,5})// inclui as configura��es da legenda

AADD(aCores,{'ALI->ALI_STATUS == "01"', 'BR_AZUL' 	 })
AADD(aCores,{'ALI->ALI_STATUS == "02"', "DISABLE"  	 })
AADD(aCores,{'ALI->ALI_STATUS == "03"', "ENABLE" 	 })
AADD(aCores,{'ALI->ALI_STATUS == "05"', "BR_LARANJA" })
AADD(aCores,{'ALI->ALI_STATUS == "04"', "BR_PRETO" 	 })
AADD(aCores,{'ALI->ALI_STATUS == "06"', "BR_CINZA" 	 })

dbSelectArea(cAlias)
dbSetOrder(1)

Eval(bFiltraBrw)         // Eval - Fun��o que EXECUTA codeblock - Aqui � que est� ocorrendo o filtro
(cAlias)->( dbGoTop() )

mBrowse( 6,1,22,75,cAlias, , , , , ,aCores)

EndFilBrw(cAlias,aIndexALI)  // Finaliza a filtragem
Return Nil


//*************************
User Function Leadleg()    // fun��o para leenda colorida
//************************* 
     aLegenda := 	{ 	{"BR_AZUL"    , "Bloqueado p/ sistema (aguardando outros niveis)"  },; 
						{"DISABLE" 		, "Aguardando Liberacao do usuario" },;	                 
						{"ENABLE"   	, "Liberado pelo usuario"  },;                           
						{"BR_LARANJA"	, "Liberado por outro usuario"  },;	                     
						{"BR_PRETO"   , "Cancelado" },;                                        
						{"BR_CINZA"		, "Cancelado por outro usuario" }}	                     
			      

BrwLegenda("Status de Libera��o da Conting�ncia!!!","Legenda",aLegenda)
return
