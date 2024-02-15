#include "totvs.ch"

/*
Programa.: CNT6001.PRW
Tipo.....: JOB 
Autor....: Odair Batista - TOTVS Unidade Londrina
Data.....: 29/07/2023
Descrição: Funções gerais de contratos
Notas....: 
*/


/*/{Protheus.doc} CNT6001
Função principal para chamada externa
@type Function
@author Odair Batista - TOTVS Unidade Londrina
@since 29/07/2023
@version 1.0
/*/
user function CNT6001()
return 


/*/{Protheus.doc} CNT6001
Função para retornar a descrição do tipo de revisão
@type Function
@author Odair Batista - TOTVS Unidade Londrina
@since 29/07/2023
@version 1.0
@param cCode, string, código do tipo da revisão
@return string, descrição do tipo da revisão
/*/
user function CNT6001A(cCode)
	local cReturn := ""

    default cCode := space(2)
    cCode := padR(cCode, 2, "")

    if cCode == "00"
        cReturn := "Implantação"
    elseIf cCode == "01"
        cReturn := "Aditivo"
    elseIf cCode == "02"
        cReturn := "Reajuste"
    elseIf cCode == "03"
        cReturn := "Realinhamento"
    elseIf cCode == "04"
        cReturn := "Readequação"
    elseIf cCode == "05"
        cReturn := "Paralisação"
    elseIf cCode == "06"
        cReturn := "Reinício"
    elseIf cCode == "07"
        cReturn := "Alteração de Cláusulas"
    elseIf cCode == "08"
        cReturn := "Contábil"
    elseIf cCode == "09"
        cReturn := "índice"
    elseIf cCode == "10"
        cReturn := "Troca de Fornecedor"
    elseIf cCode == "11"
        cReturn := "Grupos de Aprovação"
    elseIf cCode == "12"
        cReturn := "Renovação"
    elseIf cCode == "13"
        cReturn := "Multa/Bonificação"
    elseIf cCode == "14"
        cReturn := "Aberta"
    elseIf cCode == "15"
        cReturn := "Caução"
    endIf 
return(cReturn)
