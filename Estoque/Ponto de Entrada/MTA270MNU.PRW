#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MTA270MNU
//O Ponto de Entrada 'MTA270MNU', é utilizado para adicionar botões ao Menu Principal da digitação de inventário.
@author EVERTON FORTI
@since 03/10/2023
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MTA270MNU()
Local aRotina := {}

aRotina := ParamIXB

AADD(aRotina, {'Importar Planilha','U_IMPMTA270', 0 , 0})
	
Return aRotina
