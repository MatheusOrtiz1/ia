#include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA094RO
Função de chamada do ponto de entrada
@author Everton Forti - TOTVS Unidade Londrina
@since 02/12/2020
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
user function MTA094RO()
	local aRotina := paramIXB[1]
	
	aAdd(aRotina, {"Conhecimento", "MsDocument", 0, 6, 0, nil})
	aAdd(aRotina, {"Questionar", "U_PEDQUEST()", 0, 6, 0, nil})
    //aadd(aButtons,{ 'Conhecimento' ,{||  MsDocument('SC7',SC7->(RecNo()), 4) },'Conhecimento','Conhecimento' } )
return(aRotina)
