#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT140PC
Ponto de entrada para manipular a quantidade da tarefa do projeto e atribuir conforme XML, 
evitando o mensagem PMSQTNF.
@author ConexãoNF-e
@since 30/09/2022
@version 1.0
@return lRet, .T.
@see (https://atendimento.conexaonfe.com.br/kb/)
/*/
User Function MT140PC()
Local lRet := PARAMIXB[1]

    //If
	//	Regra existente
	//	[...]
	//EndIf

    // Ponto de chamada ConexãoNF-e sempre como última instrução
    U_GTPE019()

Return lRet
