#Include "Protheus.ch"

/*/{Protheus.doc} MTCOLSE2
// Ponto de entrada utilizado pelo importador da Conex�oNF-e para manipular a data de vencimento e data da duplicata
de acordo com o XML.
@author Conex�oNF-e
@since 02/03/2022
@version 1.0
@return aSE2, aCols manipulado
@see (https://atendimento.conexaonfe.com.br/kb/)
/*/
User Function MTCOLSE2()
Local aSE2 := ParamIXB[1]

	// Ponto de chamada Conex�oNF-e sempre como primeira instru��o.
	aSE2 := U_GTPE013()

	//If
	//	Regra existente
	//	[...]
	//EndIf

Return aSE2
