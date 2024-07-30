CREATE OR REPLACE VIEW CONSINCO.MLFV_AUXNOTAFISCALINCONS AS
SELECT distinct (PP.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL, -- Seq da nota
                PP.NUMERONF,
                PP.NROEMPRESA,
                0 AS SEQAUXNFITEM, -- Seq Item
                'L' AS BLOQAUTOR, -- Indica se ¿ de bloqueio(B) ou permite Libera¿¿o (L)
                51 AS CODINCONSISTENC, -- C¿digo de inconsist¿ncia. Nro Sequencial iniciando em 50
                'Nota com produtos que cobram ST por fora sem guia lançada ou valor divergente' AS MENSAGEM -- Mensagem da inconsist¿ncia
  FROM MLF_AUXNOTAFISCAL PP,
       MLF_GNRE Z,
       (SELECT X.SEQAUXNOTAFISCAL, SUM(X.VLRICMSST) VLRICMSST
          FROM MLF_AUXNFITEM X
         WHERE X.VLRICMSST > 0
           AND X.LANCAMENTOST IN ('O', 'I')
         GROUP BY X.SEQAUXNOTAFISCAL) GS
 WHERE PP.SEQAUXNOTAFISCAL = Z.SEQAUXNOTAFISCAL
   AND PP.SEQAUXNOTAFISCAL = GS.SEQAUXNOTAFISCAL
   AND ABS(GS.VLRICMSST - Z.VLRRECOLHIDO) > 1

   union all

----cr¿tica solicitada por Neides.
   SELECT distinct (a.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL, -- Seq da nota
                a.NUMERONF,
                a.NROEMPRESA,
                0 AS SEQAUXNFITEM, -- Seq Item
                'B' AS BLOQAUTOR, -- Indica se ¿ de bloqueio(B) ou permite Libera¿¿o (L)
                52 AS CODINCONSISTENC, -- C¿digo de inconsist¿ncia. Nro Sequencial iniciando em 50
                'Nota Fiscal com o CGO incorreto' AS MENSAGEM -- Mensagem da inconsist¿ncia
from MLF_AUXNOTAFISCAL a,ge_pessoa b, max_empresa c,
(select substr((lpad(a.nrocgccpf,13,0)),0,9)as raiz,b.seqpessoaemp,a.fantasia, b.nroempresa
from ge_pessoa a, max_empresa b
where a.seqpessoa = b.seqpessoaemp) d, max_codgeraloper e
where a.nroempresa = c.nroempresa
and   a.seqpessoa = b.seqpessoa
and   a.nroempresa = d.nroempresa
and   a.codgeraloper = e.codgeraloper
and substr((lpad(b.nrocgccpf,13,0)),0,9) != d.raiz
and e.cfopestado in (1209)

union all

   SELECT distinct (a.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL, -- Seq da nota
                a.NUMERONF,
                a.NROEMPRESA,
                0 AS SEQAUXNFITEM, -- Seq Item
                'B' AS BLOQAUTOR, -- Indica se ¿ de bloqueio(B) ou permite Libera¿¿o (L)
                53 AS CODINCONSISTENC, -- C¿digo de inconsist¿ncia. Nro Sequencial iniciando em 50
                'Nota Fiscal com o CGO incorreto' AS MENSAGEM -- Mensagem da inconsist¿ncia
from MLF_AUXNOTAFISCAL a,ge_pessoa b, max_empresa c,
(select substr((lpad(a.nrocgccpf,13,0)),0,9)as raiz,b.seqpessoaemp,a.fantasia, b.nroempresa
from ge_pessoa a, max_empresa b
where a.seqpessoa = b.seqpessoaemp) d, max_codgeraloper e
where a.nroempresa = c.nroempresa
and   a.seqpessoa = b.seqpessoa
and   a.nroempresa = d.nroempresa
and   a.codgeraloper = e.codgeraloper
and substr((lpad(b.nrocgccpf,13,0)),0,9) = d.raiz
and a.seqpessoa <> a.nroempresa --- Tratativa para quando empresa mata a operação para ela mesma 30/09/2022
and e.cfopestado in (1202)

union all

/* Alteracao na logica das duas críticas abaixo em solicitação de Neides - 22/11/2023 - Alterado por Giuliano

----Critica : Para Fornecedores de SP a data de emiss¿o n¿o pode ser mais do que 15 dias da data do recebimento
SELECT distinct (a.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL, -- Seq da nota
                a.NUMERONF,
                a.NROEMPRESA,
                0 AS SEQAUXNFITEM, -- Seq Item
                'L' AS BLOQAUTOR, -- Indica se ¿ de bloqueio(B) ou permite Libera¿¿o (L)
                54 AS CODINCONSISTENC, -- C¿digo de inconsist¿ncia. Nro Sequencial iniciando em 50
                'Data de Recebimento Acima de 18 Dias da Emissão Para Fornecedores de SP Data Limite : '|| to_char(a.dtaemissao + 16, 'DD/MM/YY') AS MENSAGEM -- Mensagem da inconsist¿ncia
from MLF_AUXNOTAFISCAL a, ge_pessoa b , max_empresa c
where a.nroempresa = c.nroempresa
and   a.seqpessoa = b.seqpessoa
and   b.uf = 'SP'
and a.dtaemissao <= (a.dtarecebimento - 18)   --- alteração em 13/12/2022 neides - Ticket 153066
and A.DTAEMISSAO + 180 > A.DTARECEBIMENTO -- Inconsistencia será validada pela regra COD 63

union all

----Critica : Para Todos os Fornecedores exceto SP a data de emiss¿o n¿o pode ser mais do que 20 dias da data do recebimento
 SELECT distinct (a.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL, -- Seq da nota
                a.NUMERONF,
                a.NROEMPRESA,
                0 AS SEQAUXNFITEM, -- Seq Item
                'L' AS BLOQAUTOR, -- Indica se ¿ de bloqueio(B) ou permite Libera¿¿o (L)
                55 AS CODINCONSISTENC, -- C¿digo de inconsist¿ncia. Nro Sequencial iniciando em 50
                'Data de Recebimento Acima de 32 Dias da Emissão Data Limite : '|| to_char(a.dtaemissao + 30, 'DD/MM/YY') AS MENSAGEM -- Mensagem da inconsist¿ncia
from MLF_AUXNOTAFISCAL a, ge_pessoa b , max_empresa c
where a.nroempresa = c.nroempresa
and   a.seqpessoa = b.seqpessoa
and   b.uf != 'SP'
and a.dtaemissao <= (a.dtarecebimento - 32)  --- alteração em 13/12/2022 neides - Ticket 153066
and A.DTAEMISSAO + 180 > A.DTARECEBIMENTO -- Inconsistencia será validada pela regra COD 63
*/

-- Novas:

-- 18 Dias para Emissoes na mesma UF

 SELECT DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                0 AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                54 AS CODINCONSISTENC,
                'Data de Recebimento Acima de 18 Dias da Emissão Data Limite : '|| TO_CHAR(A.DTAEMISSAO + 16, 'DD/MM/YY') AS MENSAGEM
FROM MLF_AUXNOTAFISCAL A, GE_PESSOA B , MAX_EMPRESA C
WHERE A.NROEMPRESA = C.NROEMPRESA
AND   A.SEQPESSOA = B.SEQPESSOA
AND   B.UF = C.UF
AND A.DTAEMISSAO <= (A.DTARECEBIMENTO - 18)
AND A.DTAEMISSAO + 180 > A.DTARECEBIMENTO

  UNION ALL
-- 32 Dias para Emissoes em UF diferentes

SELECT DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                0 AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                55 AS CODINCONSISTENC,
                'Data de Recebimento Acima de 32 Dias da Emissão Data Limite : '|| TO_CHAR(A.DTAEMISSAO + 30, 'DD/MM/YY') AS MENSAGEM
FROM MLF_AUXNOTAFISCAL A, GE_PESSOA B , MAX_EMPRESA C
WHERE A.NROEMPRESA = C.NROEMPRESA
AND   A.SEQPESSOA = B.SEQPESSOA
AND   B.UF != C.UF
AND A.DTAEMISSAO <= (A.DTARECEBIMENTO - 32)
AND A.DTAEMISSAO + 180 > A.DTARECEBIMENTO

union all

---CRITICA Nota com produtos que cobram ST por fora sem guia gnre lan¿ada Edvaldo
SELECT distinct (PP.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL, -- Seq da nota
PP.NUMERONF,
PP.NROEMPRESA,
0 AS SEQAUXNFITEM, -- Seq Item
'B' AS BLOQAUTOR, -- Indica se ¿ de bloqueio(B) ou permite Libera¿¿o (L)
56 AS CODINCONSISTENC, -- C¿digo de inconsist¿ncia. Nro Sequencial iniciando em 50
'Nota com produtos que cobram ST por fora sem guia lançada ou valor divergente (V2-COD 56)' AS MENSAGEM -- Mensagem da inconsist¿ncia
FROM CONSINCO.MLF_AUXNOTAFISCAL PP
WHERE PP.SEQAUXNOTAFISCAL IN
(SELECT C.SEQAUXNOTAFISCAL
FROM MLF_AUXNFITEM C
WHERE C.VLRICMSST > 0
AND C.LANCAMENTOST IN ('O', 'I'))
AND PP.SEQAUXNOTAFISCAL NOT IN
(SELECT Z.SEQAUXNOTAFISCAL FROM MLF_GNRE Z)

union all

-- Critica para bloquear recebimento de notas que não esteja vinculadas a notas de remessa. Ticket 11783532
   SELECT distinct (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL, -- Seq da nota
                A.NUMERONF,
                A.NROEMPRESA,
                0 AS SEQAUXNFITEM, -- Seq Item
                'B' AS BLOQAUTOR, -- Indica se ¿ de bloqueio(B) ou permite Libera¿¿o (L)
                57 AS CODINCONSISTENC, -- C¿digo de inconsist¿ncia. Nro Sequencial iniciando em 50
                'Nota Fiscal de remessa não está vinculada a essa NF' AS MENSAGEM -- Mensagem da inconsistência
  FROM consinco.MLF_AUXNOTAFISCAL A
 WHERE A.CODGERALOPER IN (121,116)
  --- Trecho abaixo adicionado devido a mudança de estrutura da nova versão 22.01 - Cipolla / Paloma 28/06/2022
   AND not EXISTS (select 1
  from CONSINCO.MLF_NFCOMPRAREMESSARELAC
 where (SEQIDENTIFICAORIGEM = a.seqauxnotafiscal OR SEQIDENTIFICARELACIONADO = a.seqauxnotafiscal)
   AND TIPORELACIONADO = 'M')


/*   union all -- Retirado critica pois foi alterado parametro dinamico, ticket 12339992

   -- Critica para bloquear notas do RJ onde o Vlr da Nota está diferente do Vlr XML com oirgem do CD
--- Ticket 11835472
SELECT distinct (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL, -- Seq da nota
                A.NUMERONF,
                A.NROEMPRESA,
                0 AS SEQAUXNFITEM, -- Seq Item
                'B' AS BLOQAUTOR, -- Indica se ¿ de bloqueio(B) ou permite Libera¿¿o (L)
                58 AS CODINCONSISTENC, -- C¿digo de inconsist¿ncia. Nro Sequencial iniciando em 50
                'Valor Total da Nota Fiscal' || ' - R$ '||A.VLRTOTALNF|| ' está divergente do valor total do XML - R$ '||B.m000_vl_nf AS MENSAGEM -- Mensagem da inconsist¿ncia
  FROM consinco.MLF_AUXNOTAFISCAL A INNER JOIN consinco.tmp_m000_nf b ON (a.nfechaveacesso = b.m000_nr_chave_acesso )
 WHERE b.m000_vl_nf != a.vlrtotalnf ---- Onde valores sejam diferentes
 AND a.nroempresa = 36 --- Apenas loja do RJ
 and a.seqpessoa in (501,502,503,504,505,506) -- Origem apenas do CD*/

 union all

/* Crítica abaixo será tratada pelas novas 74 e 75

 -- Critica solicitada pelo Juan para não permitir entrada de produtos de uso e consumo que não sejam no CGO 02 08/09/2021 Cipolla
 --- Solicitação do Juan 06/09/2021
 SELECT distinct (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL, -- Seq da nota
                A.NUMERONF,
                A.NROEMPRESA,
                b.seqauxnfitem AS SEQAUXNFITEM, -- Seq Item
                'L' AS BLOQAUTOR, -- Indica se ¿ de bloqueio(B) ou permite Libera¿¿o (L)
                58 AS CODINCONSISTENC, -- C¿digo de inconsist¿ncia. Nro Sequencial iniciando em 50
                'Item ' || b.seqproduto || ' está cadastrado com a Finalidade "Material de Uso e Consumo", portanto, só poderá ser lançado no CGO 02, 22, 59 ou 61' as  MENSAGEM -- Mensagem da inconsist¿ncia
  FROM consinco.MLF_AUXNOTAFISCAL A INNER JOIN consinco.Mlf_Auxnfitem b ON (a.seqauxnotafiscal = b.seqauxnotafiscal )
                                                                           inner join consinco.map_produto c on (c.seqproduto = b.seqproduto)
                                                                           inner join consinco.map_famdivisao e on (e.seqfamilia = c.seqfamilia)
  where e.finalidadefamilia = 'U'                                                                               --- Incluido CGOS 69,135,202 em 19/01/2022 por Cipolla - Solicitação Juan
  and   a.codgeraloper not in (2,22,59,61,128,65,652,950,141,69,135,202,126,14,127,27,139) --- Solicitação Juan 128, 65 e 652 em 10/12/2021 - Alterado por Cipolla- Incluido CGO 950 em 14/12 solciitação Juan - Incuido CGO 141 Solicitação Juan em 05/01/2022
                                                                                                                                         ---- CGO 126,14 incluido em 15/09/2022 solicitação Neides cvia Teamns
                                                                                                                                         ---- CGO 127 - 16/11/2022 Giuliano - Ticket 138456 / ticket 200078 16/03/2023 CGO 27
                                                                                                                                         ---- CGO 139 incluido em 31/08/2023 por Giuliano | Ticket 281742 - Solic Rafael/Silene
  and a.nroempresa < 500
--  and a.nroempresa = 14

union all
*/
   --- Critica solicitada pela Daniele do Fiscal - Ticket 97671 - Criado por Cipolla em 14/11/2022
	 --- Essa view vai tratar apenas as consistencias de Pis e Cofins quando CGO for de entrada comum, bonificações estão sendo tratadas na view abaixo..
 SELECT  /*+optimizer_features_enable('11.2.0.4') */
                distinct (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                a.numeronf,
                A.NROEMPRESA,
                b.seqauxnfitem AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                59 AS CODINCONSISTENC,
                'O Item ' || b.seqproduto || ' está com PIS/COFINS divergente, entrar em contato com o departamento fiscal - Tipo de Fornecedor: '||decode(f.TIPO,'M','Simples Nacional','I','Industria','D','Distribuidor') as  MENSAGEM
  FROM consinco.MLF_AUXNOTAFISCAL A INNER JOIN consinco.Mlf_Auxnfitem b ON (a.seqauxnotafiscal = b.seqauxnotafiscal )
                                                                           inner join consinco.map_produto c on (c.seqproduto = b.seqproduto)
                                                                           inner join consinco.map_familia e on (e.seqfamilia = c.seqfamilia)
                                                                           inner join NAGV_FORNTIPO f on (f.seqfornecedor = a.seqpessoa) --- view tipo fornecedor
                                                                           inner join TMP_M000_NF k on (k.m000_nr_chave_acesso = a.nfechaveacesso)
                                                                           inner join TMP_M014_ITEM l on (l.m000_id_nf = k.m000_id_nf and l.m014_nr_item = b.seqitemnfxml  )
  where 1=1
  and  exists (select 1 from max_codgeraloper z where z.codgeraloper = a.codgeraloper and z.tipuso = 'R') --- Apenas CGo de Recebimento
  and not exists (select 1 from ge_empresa ge where ge.seqpessoa = a.seqpessoa) --- Retirar empresas do Grupo Nagumo
  -- 136 Adicionado por Giuliano - Solic Danielle - Ticket 368314 - 11/03/24
  and a.codgeraloper not  in (126,816,101,128,208,239,117,14,127,65, 116, 139, 652, 143,900,107,206,939,279,136) --- Dani solicitou que Bonificalções tem tratamento diferente, será acrescido na critica abaixo. Retirado CGO 279 DANI em 28/02/2024
  -- COFINS
  and (not exists (select 1 From NAGT_ENTRADAPISCOFINS r where (l.m014_dm_st_trib_cf = r.cst_saidafornecedor OR l.M014_Dm_St_Trib_Pis = r.cst_saidafornecedor )
  and r.cst_entranagumo =  e.situacaonfpis and f.TIPO = r.fornecedor and r.tipo = 'N' --- De x Para tipo fornecedor com CST Saída x Entrada
                                                         -- Adicionado por Giuliano em 04/01/2024 - Solic Danielle - Ticket 339477
                                                         -- Começa a tratar permissao por UF - UF_PERM adicionada na tabela de/para NAGT_ENTRADAPISCOFINS
                                                          AND (UF_PERM IS NULL OR
                                                               UF_PERM LIKE '%'||(SELECT UF FROM GE_PESSOA GEP WHERE GEP.SEQPESSOA = A.SEQPESSOA)||'%'))
  -- PIS
    OR not exists (select 1 From NAGT_ENTRADAPISCOFINS r where l.M014_Dm_St_Trib_Pis = r.cst_saidafornecedor and r.cst_entranagumo =  e.situacaonfpis and r.fornecedor = F.TIPO and r.tipo = 'N' --- De x Para tipo fornecedor com CST Saída x Entrada
                                                          AND (UF_PERM IS NULL OR
                                                               UF_PERM LIKE '%'||(SELECT UF FROM GE_PESSOA GEP WHERE GEP.SEQPESSOA = A.SEQPESSOA)||'%')))
  -- Alterado por Giuliano em 06/10/2023 - Solic Danielle/Neides - Ticket 300200
  -- Retirado fornecedores Micro Empresa e Pis/Cofins 49 no Cadastro do Fornecedor
  AND NOT EXISTS (
  SELECT 1
    FROM CONSINCO.MAF_FORNECDIVISAO FD INNER JOIN MAF_FORNECEDOR FF ON FF.SEQFORNECEDOR = FD.SEQFORNECEDOR
   WHERE FD.PERPISDIF    = 49
     AND FD.PERCOFINSDIF = 49
     AND FF.MICROEMPRESA != 'S'
     AND FD.SEQFORNECEDOR = A.SEQPESSOA)

	union all

		--- Critica solicitada pela Daniele do Fiscal - Ticket 97671 - Criado por Cipolla em 14/11/2022
	 --- Essa view vai tratar apenas as consistencias de Pis e Cofins quando CGO for de bonificação.
 SELECT  /*+optimizer_features_enable('11.2.0.4') */
                distinct (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                a.numeronf,
                A.NROEMPRESA,
                b.seqauxnfitem AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                60 AS CODINCONSISTENC,
                'O Item ' || b.seqproduto || ' está com PIS/COFINS divergente, entrar em contato com o departamento fiscal - Tipo de Fornecedor: '||decode(f.TIPO,'M','Simples Nacional','I','Industria','D','Distribuidor') as  MENSAGEM
  FROM consinco.MLF_AUXNOTAFISCAL A INNER JOIN consinco.Mlf_Auxnfitem b ON (a.seqauxnotafiscal = b.seqauxnotafiscal )
                                                                           inner join consinco.map_produto c on (c.seqproduto = b.seqproduto)
                                                                           inner join consinco.map_familia e on (e.seqfamilia = c.seqfamilia)
                                                                           inner join NAGV_FORNTIPO f on (f.seqfornecedor = a.seqpessoa) --- view tipo fornecedor
                                                                           inner join TMP_M000_NF k on (k.m000_nr_chave_acesso = a.nfechaveacesso)
                                                                           inner join TMP_M014_ITEM l on (l.m000_id_nf = k.m000_id_nf and l.m014_nr_item = b.seqitemnfxml  )  --- alteração Cipolla de seqauxnfitem Para seqitemnfxml
  where 1=1
  and not exists (select 1 from ge_empresa ge where ge.seqpessoa = a.seqpessoa) --- Retirar empresas do Grupo Nagumo
  and a.codgeraloper in (126,816,101,128,208,239,117,14,127,65, 116, 139, 652, 143,900,107) --- Bonificações Ticket 194151 Dani em 02/03/2023 Cipolla CGO 900
   -- COFINS
  and (not exists (select 1 From NAGT_ENTRADAPISCOFINS r where (l.m014_dm_st_trib_cf = r.cst_saidafornecedor OR l.M014_Dm_St_Trib_Pis = r.cst_saidafornecedor )
  and r.cst_entranagumo =  e.situacaonfpis and r.fornecedor = F.GERAL and r.tipo = 'B' --- De x Para tipo fornecedor com CST Saída x Entrada
                                                         -- Adicionado por Giuliano em 04/01/2024 - Solic Danielle - Ticket 339477
                                                         -- Começa a tratar permissao por UF - UF_PERM adicionada na tabela de/para NAGT_ENTRADAPISCOFINS
                                                          AND (UF_PERM IS NULL OR
                                                               UF_PERM LIKE '%'||(SELECT UF FROM GE_PESSOA GEP WHERE GEP.SEQPESSOA = A.SEQPESSOA)||'%'))
  -- PIS
    OR not exists (select 1 From NAGT_ENTRADAPISCOFINS r where l.M014_Dm_St_Trib_Pis = r.cst_saidafornecedor and r.cst_entranagumo =  e.situacaonfpis and r.fornecedor = F.GERAL and r.tipo = 'B' --- De x Para tipo fornecedor com CST Saída x Entrada
                                                          AND (UF_PERM IS NULL OR
                                                               UF_PERM LIKE '%'||(SELECT UF FROM GE_PESSOA GEP WHERE GEP.SEQPESSOA = A.SEQPESSOA)||'%')))
  -- Alterado por Giuliano em 06/10/2023 - Solic Danielle/Neides - Ticket 300200
  -- Retirado fornecedores Micro Empresa e Pis/Cofins 49 no Cadastro do Fornecedor
  AND NOT EXISTS (
  SELECT 1
    FROM CONSINCO.MAF_FORNECDIVISAO FD INNER JOIN MAF_FORNECEDOR FF ON FF.SEQFORNECEDOR = FD.SEQFORNECEDOR
   WHERE FD.PERPISDIF    = 49
     AND FD.PERCOFINSDIF = 49
     AND FF.MICROEMPRESA != 'S'
     AND FD.SEQFORNECEDOR = A.SEQPESSOA)

UNION ALL

 -- Giuliano | 23/12/2022 | Solicitação Neides - Ticket 99791
 -- Não permite entrada com frete tipo FOB
SELECT DISTINCT(X.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                X.NUMERONF,
                X.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                61  AS CODINCONSISTENC,
                'FRETE DIVERGENTE- VERIFICAR COMPRADOR CIF OU FOB? - Se errado C5: Cadastro Comercial | Errado XML: Troca de Nota' AS MENSAGEM

  FROM MLF_AUXNOTAFISCAL X
 WHERE X.TIPFRETETRANSP = 'F'

UNION ALL -- Trava lançamentos com vencimento menor que a data do pedido - Giuliano - Solicitação Ronie

SELECT DISTINCT(X.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                X.NUMERONF,
                X.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                62  AS CODINCONSISTENC,
                'Prazo de Vencimento Informado MENOR que o Prazo do Pedido' /*- Pedido: '||MP.NROPEDIDOSUPRIM||
                ' - Prazo: '||MP.PZOPAGAMENTO||TO_CHAR((MP.DTAEMISSAO + MP.PZOPAGAMENTO), 'DD/MM/YYYY')*/
                -- Irá constar erro caso tenha mais que um pedido divergente
                AS MENSAGEM

  FROM MLF_AUXNOTAFISCAL X INNER JOIN MLF_AUXNFVENCIMENTO MA ON MA.SEQAUXNOTAFISCAL = X.SEQAUXNOTAFISCAL
                           INNER JOIN MLF_AUXNFITEM XA       ON X.SEQAUXNOTAFISCAL  = XA.SEQAUXNOTAFISCAL AND XA.SITUACAONF != 'C'
                           INNER JOIN MSU_PEDIDOSUPRIM MP    ON XA.NROPEDIDOSUPRIM  = MP.NROPEDIDOSUPRIM  AND MP.SITUACAOPED != 'C'
                                                                                                          AND MP.CENTRALLOJA = XA.CENTRALLOJA
                                                                                                          AND X.NROEMPRESA = MP.NROEMPRESA
                           INNER JOIN MAF_FORNECDIVISAO MF   ON MF.SEQFORNECEDOR    = MP.SEQFORNECEDOR

 WHERE MA.DTAVENCIMENTO < DECODE(MF.INDPZOPAGAMENTO, 'F', -- Forma de pagamento Faturamento
                  DECODE(MF.TIPODTABASEVENCTO, 'E', X.DTAEMISSAO, 'R', X.DTARECEBIMENTO, 'S', X.DTASAIDA) +
                  CASE WHEN MP.PZOPAGAMENTO LIKE '%/%' THEN REGEXP_SUBSTR(REPLACE(MP.PZOPAGAMENTO, '/',' '), '(\S*)(\s)',1)
                       ELSE MP.PZOPAGAMENTO END,
                  -- Function para tratar outras formas de pagamento de acordo com o cadastro (Fora a Dezena, Quinzena, Semana ou Mês)
                  FMAD_CALCDTAVENCTO((DECODE(MF.TIPODTABASEVENCTO, 'E', X.DTAEMISSAO, 'R', X.DTARECEBIMENTO, 'S', X.DTASAIDA)), MF.INDPZOPAGAMENTO,
                  CASE WHEN MP.PZOPAGAMENTO LIKE '%/%' THEN REGEXP_SUBSTR(REPLACE(MP.PZOPAGAMENTO, '/',' '), '(\S*)(\s)',1)
                       ELSE MP.PZOPAGAMENTO END, NULL)) -1 -- 1 Dia de Margem Aceitável

   AND MP.PZOPAGAMENTO IS NOT NULL
   AND X.NUMERONF != 0
	 AND X.SEQPESSOA NOT IN (120186, 117952, 116561,1907856) --- Não Criticar Fornecedores Unilever e Colgate Chamado 321883 - Solicitação Thaise e Miriam + 1907856 EX
   AND MP.TIPPEDIDOSUPRIM NOT IN ('X','T')

UNION ALL -- Trava para barrar entrada com CGO 200/900 e CST <> 000,020,040 - 01/02/2023 - Giuliano - Solic Danielle - Ticket 175967

SELECT DISTINCT(A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                62  AS CODINCONSISTENC,
                'Produto ST não permite entrada para este fornecedor'

                FROM consinco.MLF_AUXNOTAFISCAL A INNER JOIN consinco.Mlf_Auxnfitem b    ON A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL
                                                  INNER JOIN CONSINCO.MAP_PRODUTO    P   ON P.SEQPRODUTO = B.SEQPRODUTO
                                                  INNER JOIN CONSINCO.MAP_FAMDIVISAO FF  ON FF.SEQFAMILIA = P.SEQFAMILIA
                                                  LEFT JOIN  CONSINCO.MAF_FORNECEDOR MF  ON MF.SEQFORNECEDOR = A.SEQPESSOA
                                                  INNER JOIN CONSINCO.MAP_TRIBUTACAOUF T ON T.NROTRIBUTACAO = FF.NROTRIBUTACAO AND T.NROREGTRIBUTACAO = 0
                                                                                         AND T.TIPTRIBUTACAO = DECODE (MF.TIPFORNECEDOR, 'I','EI','D','ED')

WHERE A.CODGERALOPER IN (200,900) AND (B.SITUACAONF NOT IN (000,020,040) OR T.SITUACAONF NOT IN (000,020,040)) AND NUMERONF != 0

UNION ALL -- TIcket 184335 - Solic Danielle - Adicionado por Giuliano - 08/02/2023

SELECT distinct (a.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL, -- Seq da nota
                a.NUMERONF,
                a.NROEMPRESA,
                0 AS SEQAUXNFITEM, -- Seq Item
                'L' AS BLOQAUTOR, -- Indica se ¿ de bloqueio(B) ou permite Libera¿¿o (L)
                63 AS CODINCONSISTENC, -- C¿digo de inconsist¿ncia. Nro Sequencial iniciando em 50
                'NF excedeu o prazo de 180 dias e não pode ser recebida - Data Limite : '|| to_char(a.DTAEMISSAO + 180, 'DD/MM/YY') AS MENSAGEM -- Mensagem da inconsist¿ncia
from MLF_AUXNOTAFISCAL a, ge_pessoa b , max_empresa c
where a.nroempresa = c.nroempresa
and   a.seqpessoa = b.seqpessoa
and a.dtaemissao + 180 < a.dtarecebimento
--AND A.CODGERALOPER NOT IN (17,117,652)-- Solicitado por Silene - Ticket 203362 - Alterado por Giuliano - 17/03/2023 -- Retirado - Ticket 219168 19/04/2023

UNION ALL

-- Ticket 206722 - Adicionado por Giuliano - Solic Danielle 20/03
-- Regra: Trava 4 dígitos do NCM diferentes entre XML e C5

SELECT DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                64  AS CODINCONSISTENC,
                'Produto '||B.SEQPRODUTO||' com NCM incorreto, abrir chamado para o Depto. Fiscal Cad. Trib. para correção - XML: '||M014_CD_NCM||' - C5: '||E.CODNBMSH MENSAGEM

  FROM CONSINCO.MLF_AUXNOTAFISCAL A INNER JOIN CONSINCO.MLF_AUXNFITEM B ON A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL
                                    INNER JOIN CONSINCO.MAP_PRODUTO C ON B.SEQPRODUTO = C.SEQPRODUTO
                                    INNER JOIN CONSINCO.MAP_FAMILIA E ON E.SEQFAMILIA = C.SEQFAMILIA
                                    INNER JOIN CONSINCO.MAP_FAMDIVISAO D ON D.SEQFAMILIA = E.SEQFAMILIA
                                    INNER JOIN TMP_M000_NF K ON (K.M000_NR_CHAVE_ACESSO = A.NFECHAVEACESSO)
                                    INNER JOIN TMP_M014_ITEM L ON (L.M000_ID_NF = K.M000_ID_NF AND L.M014_NR_ITEM = B.SEQITEMNFXML)

WHERE SUBSTR(M014_CD_NCM,0,4) != SUBSTR(E.CODNBMSH,0,4) AND A.SEQPESSOA > 999

UNION ALL

-- Ticket 204660 - Adicionado por Giuliano - Solic Danielle 30/03
-- Regra: Trava Cod Origem XML = 0 e C5 1,2,3,8 || OU || XML: 1,2,3,8 e C5 0,4,5,7
-- Ultima atualizacao em 21/11/2023 - Ticket 320474
-- Alterado em 25/06/24 por Giuliano - Ticket 417539 - Barrar todas divergencias
-- Alterado em 28/06/24 por Giuliano - Ticket 419280 - Altera regra para FLV

SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4')*/
       DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                65  AS CODINCONSISTENC,
                'Produto: '||B.SEQPRODUTO||' com Cod. Origem incorreto, abrir chamado para o Depto. Fiscal Cad. Trib. para correção - XML: '||L.M014_DM_ORIG_ICMS||' - C5: '||D.CODORIGEMTRIB  MENSAGEM

  FROM CONSINCO.MLF_AUXNOTAFISCAL A INNER JOIN CONSINCO.MLF_AUXNFITEM B ON A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL
                                    INNER JOIN CONSINCO.MAP_PRODUTO C ON B.SEQPRODUTO = C.SEQPRODUTO
                                    INNER JOIN CONSINCO.MAP_FAMILIA E ON E.SEQFAMILIA = C.SEQFAMILIA
                                    INNER JOIN CONSINCO.MAP_FAMDIVISAO D ON D.SEQFAMILIA = E.SEQFAMILIA
                                    INNER JOIN TMP_M000_NF K ON (K.M000_NR_CHAVE_ACESSO = A.NFECHAVEACESSO)
                                    INNER JOIN TMP_M014_ITEM L ON (L.M000_ID_NF = K.M000_ID_NF AND L.M014_NR_ITEM = B.SEQITEMNFXML)
                                    --INNER JOIN DIM_CATEGORIA@CONSINCODW DC ON DC.SEQFAMILIA = E.SEQFAMILIA

-- Alterado em 25/06/24 por Giuliano - Ticket 417539 - Barrar todas divergencias
/*
WHERE L.M014_DM_ORIG_ICMS IN (1,2,3,8) AND D.CODORIGEMTRIB IN (0,4,5,7) AND A.SEQPESSOA > 999
   OR L.M014_DM_ORIG_ICMS IN (0,4,5,7) AND D.CODORIGEMTRIB IN (1,2,3,8) AND A.SEQPESSOA > 999

   -- INVERSO

   OR D.CODORIGEMTRIB IN (1,2,3,8) AND L.M014_DM_ORIG_ICMS IN (0,4,5,7) AND A.SEQPESSOA > 999
   OR D.CODORIGEMTRIB IN (0,4,5,7) AND L.M014_DM_ORIG_ICMS IN (1,2,3,8) AND A.SEQPESSOA > 999
*/
WHERE NVL(L.M014_DM_ORIG_ICMS,1) != NVL(D.CODORIGEMTRIB,2)
  AND A.SEQPESSOA > 999
 -- AND (A.NROEMPRESA IN (1,2,3,7,11,26,31,42,51,53,501) OR A.NROEMPRESA <= 30) -- Solic Neides/Dani
  AND A.DTAEMISSAO > SYSDATE - 50
--
-- Alterado em 28/06/24 por Giuliano - Ticket 419280 - Altera regra para FLV
  AND NOT EXISTS (SELECT 1 FROM DIM_CATEGORIA@CONSINCODW DC WHERE DC.SEQFAMILIA = C.SEQFAMILIA AND DC.CATEGORIAN1 = 'HORTIFRUTI')
--
   OR EXISTS (SELECT 1 FROM DIM_CATEGORIA@CONSINCODW DC WHERE DC.SEQFAMILIA = C.SEQFAMILIA AND DC.CATEGORIAN1 = 'HORTIFRUTI')
  AND A.SEQPESSOA > 999
  AND A.DTAEMISSAO > SYSDATE - 50

  AND(NVL(L.M014_DM_ORIG_ICMS,1) IN (2,3,8)   AND NVL(D.CODORIGEMTRIB,2) IN (0,4,5,7)
   OR NVL(L.M014_DM_ORIG_ICMS,1) IN (0,4,5,7) AND NVL(D.CODORIGEMTRIB,2) IN (2,3,8))
--
UNION ALL

-- Ticket 219089 - Solic. Simone | Adicionado por Giuliano em 20/04/2023 - Validação GNRE tipo DARE

SELECT DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                65  AS CODINCONSISTENC,
                CASE WHEN CODOBRIGREC != '005' AND CODRECEITA NOT IN ('063-2','100-4') THEN 'O Código da obrigação a recolher e o Código da Receita estão incorretos'
                  WHEN CODOBRIGREC != '005' THEN 'O Código da obrigação a recolher está incorreto'
                  WHEN CODRECEITA NOT IN ('063-2','100-4') THEN 'O Código da Receita está incorreto' ELSE NULL END
                ||' na Guia de Recolhimento - Verificar com o Depto. Fiscal' MENSAGEM

  FROM CONSINCO.MLF_AUXNOTAFISCAL A INNER JOIN CONSINCO.MLF_GNRE B ON A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL

WHERE TIPOGUIA = 'R' AND (CODOBRIGREC != '005' OR CODRECEITA NOT IN ('063-2','100-4'))

UNION ALL

-- Ticket 244728 - Solic Rafael Recebimento | Adicionado por Giuliano em 15/06/2023
-- Trava geração de recebimento de notas que forem deletadas e importadas novamente (CD x Lojas | Lojas x CD)
/*
SELECT DISTINCT(X.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                X.NUMERONF,
                X.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                66  AS CODINCONSISTENC,
                'NF não pode ser importada novamente. Entre em contato com Fiscal Apoio de sua região' AS MENSAGEM

  FROM MLF_AUXNOTAFISCAL X
 WHERE 1=1
   AND NVL(X.APPORIGEM,0) != 9 -- Ao excluír a nota da tela de recebimento, o 'APPORIGEM' é definido como NULO
   AND USULANCTO != 'CONSINCO'
   AND NUMERONF  != 0
   AND X.STATUSNF != 'C'
   AND (SEQPESSOA IN (501,506)
        OR NROEMPRESA IN (501,506) AND SEQPESSOA < 100)

UNION ALL */

SELECT DISTINCT(X.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                X.NUMERONF,
                X.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'B' AS BLOQAUTOR,
                67  AS CODINCONSISTENC,
                /*'Comprador não possúi limite disponível. Valor Itens sem Pedidos: R$ '||
                TO_CHAR(
                 SUM(Y.VLRITEM) --+ SUM(Y.VLRIPI) + SUM(Y.VLRICMS) + SUM(Y.VLRDESPTRIBUTITEM) + SUM(Y.VLRPIS) + SUM(Y.VLRCOFINS)
               - SUM(Y.VLRDESCITEM) - SUM(NVL(Y.VLRDESCFINANCEIRO,0)),
               'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''')||' Valor Disponível: R$ '||
                TO_CHAR(VLRDISPONIVEL,'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''')||' Entre em contato com o Departamento Comercial.' */
                'Não existe saldo disponível para o comprador para recebimento sem pedido. Entre em contato com o Departamento Comercial'
                AS MENSAGEM

  FROM MLF_AUXNOTAFISCAL X INNER JOIN MLF_AUXNFITEM Y ON Y.SEQAUXNOTAFISCAL = X.SEQAUXNOTAFISCAL
                           INNER JOIN MAP_PRODUTO   P ON P.SEQPRODUTO = Y.SEQPRODUTO
                           INNER JOIN MAP_FAMDIVISAO F ON F.SEQFAMILIA = P.SEQFAMILIA
                           INNER JOIN NAGV_LIMITECOMPRADOR NV ON NV.SEQCOMPRADOR = F.SEQCOMPRADOR
                           INNER JOIN MLF_AUXNFINCONSISTENCIA A ON A.SEQAUXNOTAFISCAL = X.SEQAUXNOTAFISCAL AND A.SEQAUXNFITEM = Y.SEQAUXNFITEM

 WHERE A.CODINCONSIST IN (7)
   AND A.AUTORIZADA = 'N'
   AND A.TIPOINCONSIST = 'P'
   AND X.DTAENTRADA > SYSDATE - 100
 GROUP BY X.SEQAUXNOTAFISCAL, X.NUMERONF, X.NROEMPRESA, VLRDISPONIVEL

HAVING SUM(Y.VLRITEM)
     - SUM(Y.VLRDESCITEM) > VLRDISPONIVEL

UNION ALL

-- Ticket 291664 - Solic Dublia | Adicionado em 26/09/2023 por Giuliano

SELECT  /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4') */
          DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
          A.NUMERONF,
          A.NROEMPRESA,
          B.SEQAUXNFITEM AS SEQAUXNFITEM,
          'B' AS BLOQAUTOR,
          68 AS CODINCONSISTENC,
          'Produto: '||B.SEQPRODUTO||' Com CFOP: '||M014_CD_CFOP||' apenas pode ser lançado com CGO de Bonificação. Entre em contato com seu apoio' MENSAGEM
  FROM CONSINCO.MLF_AUXNOTAFISCAL A INNER JOIN CONSINCO.MLF_AUXNFITEM B ON (A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL )
                                    INNER JOIN CONSINCO.MAP_PRODUTO C ON (C.SEQPRODUTO = B.SEQPRODUTO)
                                    INNER JOIN CONSINCO.MAP_FAMILIA E ON (E.SEQFAMILIA = C.SEQFAMILIA)
                                    INNER JOIN NAGV_FORNTIPO F ON (F.SEQFORNECEDOR = A.SEQPESSOA) --- VIEW TIPO FORNECEDOR
                                    INNER JOIN TMP_M000_NF K ON (K.M000_NR_CHAVE_ACESSO = A.NFECHAVEACESSO)
                                    INNER JOIN TMP_M014_ITEM L ON (L.M000_ID_NF = K.M000_ID_NF AND L.M014_NR_ITEM = B.SEQITEMNFXML)

 WHERE M014_CD_CFOP IN (5910,6910) AND A.CODGERALOPER NOT IN (101,128,143,239,208)

UNION ALL

-- Ticket 308911 - Solic Neides - Adicionado em 31/10/2023 por Giuliano
-- Barra XML sem emissão/ocorrencia de transporte (Cod. 9)
--- Adicionado CGO 214, saldo transferencia de saldo devedor, não tem transporte. Cipolla 20/02/2024

SELECT DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                69  AS CODINCONSISTENC,
                'XML sem ocorrencia de transporte - Solicite a nota correta para o fornecedor - Duvidas entre contato setor Fiscal' MENSAGEM

  FROM CONSINCO.MLF_AUXNOTAFISCAL A INNER JOIN CONSINCO.MLF_AUXNFITEM B ON A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL
                                    INNER JOIN CONSINCO.MAP_PRODUTO C ON B.SEQPRODUTO = C.SEQPRODUTO
                                    INNER JOIN CONSINCO.TMP_M000_NF K ON (K.M000_NR_CHAVE_ACESSO = A.NFECHAVEACESSO)
                                    INNER JOIN CONSINCO.TMP_M006_TRANSPORTE T ON T.M000_ID_NF = K.M000_ID_NF

 WHERE M006_DM_FRETE = 9
   AND A.DTAENTRADA > SYSDATE - 100
   AND A.CODGERALOPER not in ( 939,214)

UNION ALL

-- Ticket 306519 - Solic Simone - Adicionado em 31/10/2023 por Giuliano
-- Barra indFinal = 1 - Consumidor Final - No CGO 01

SELECT DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                70  AS CODINCONSISTENC,
                'Indicador de operação da nota fiscal ( consumidor final ) divergente da finalidade do CGO - Solicitar a troca da nota' MENSAGEM

  FROM CONSINCO.MLF_AUXNOTAFISCAL A INNER JOIN CONSINCO.MLF_AUXNFITEM B ON A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL
                                    INNER JOIN CONSINCO.MAP_PRODUTO C ON B.SEQPRODUTO = C.SEQPRODUTO
                                    INNER JOIN CONSINCO.TMP_M000_NF K ON (K.M000_NR_CHAVE_ACESSO = A.NFECHAVEACESSO)

 WHERE 1=1
   AND K.M000_INDFINAL = 1
   AND A.CODGERALOPER  IN (1, 101, 143, 208, 239, 900) -- Ajustado em 06/02/24 TIcket 366778 - Solic Simone
   AND A.DTAENTRADA > SYSDATE - 100

UNION ALL

-- Ticket 312166 - Solic Simone - Adicionado em 06/11/2023 por Giuliano
-- Barra CST 70 na bonif 101 e fornec Simples Nacional

SELECT DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                71  AS CODINCONSISTENC,
                'Nota fiscal bonificada com produto monofásico, por favor entrar em contato com o Departamento Fiscal.'  MENSAGEM

  FROM CONSINCO.MLF_AUXNOTAFISCAL A INNER JOIN CONSINCO.MLF_AUXNFITEM B ON A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL
                                    INNER JOIN CONSINCO.MAP_PRODUTO C ON B.SEQPRODUTO = C.SEQPRODUTO
                                    INNER JOIN CONSINCO.MAP_FAMILIA F ON F.SEQFAMILIA = C.SEQFAMILIA
                                    INNER JOIN CONSINCO.MAF_FORNECEDOR FO ON FO.SEQFORNECEDOR = A.SEQPESSOA

 WHERE (F.SITUACAONFPIS = 70 OR F.SITUACAONFCOFINS = 70)
   AND A.DTAENTRADA > SYSDATE - 50
   AND A.CODGERALOPER = 101
   AND FO.MICROEMPRESA = 'S'

UNION ALL

-- Ticket 320466 - Solic Danielle - Adicionado em 21/11/2023 por Giuliano
-- Barra Cod. Origem NULO no sistema

SELECT DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'B' AS BLOQAUTOR,
                72  AS CODINCONSISTENC,
                'Produto: '||B.SEQPRODUTO||' s/Cod.Origem - Abrir chamado para o Depto Cad.Trib.para correção XML: '||L.M014_DM_ORIG_ICMS||' -  C5 sem informação' MENSAGEM

  FROM CONSINCO.MLF_AUXNOTAFISCAL A INNER JOIN CONSINCO.MLF_AUXNFITEM B ON A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL
                                    INNER JOIN CONSINCO.MAP_PRODUTO C ON B.SEQPRODUTO = C.SEQPRODUTO
                                    INNER JOIN CONSINCO.MAP_FAMILIA E ON E.SEQFAMILIA = C.SEQFAMILIA
                                    INNER JOIN CONSINCO.MAP_FAMDIVISAO D ON D.SEQFAMILIA = E.SEQFAMILIA
                                    INNER JOIN TMP_M000_NF K ON (K.M000_NR_CHAVE_ACESSO = A.NFECHAVEACESSO)
                                    INNER JOIN TMP_M014_ITEM L ON (L.M000_ID_NF = K.M000_ID_NF AND L.M014_NR_ITEM = B.SEQITEMNFXML)

WHERE D.CODORIGEMTRIB IS NULL

UNION ALL

-- Ticket 324275 - Solic Simone - Adicionado em 04/12/2023 por Giuliano
-- Barra CEST NULO / CEST ou NCM divergente do cad no sistema

SELECT DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                73  AS CODINCONSISTENC,
                CASE WHEN L.CODCEST IS NULL                                                                    THEN 'Cod. CEST do produto '||
                  B.SEQPRODUTO||' no XML está NULO - Abrir chamado para do Departamento Fiscal - CEST XML: '||NVL(TO_CHAR(L.CODCEST), 'NULO')||' - C5: '||E.CODCEST
                    -- WHEN NVL(L.CODCEST,0) != NVL(E.CODCEST,0) AND NVL(L.M014_CD_NCM,0) != NVL(CODNBMSH,0)   THEN 'Codigo CEST e NCM do produto '||B.SEQPRODUTO||' no  XML estão divergentes do cadastro no sistema - Abrir chamado para o Depto Cadastro Tributário'
                     WHEN NVL(L.CODCEST,0) != NVL(E.CODCEST,0) /*AND NVL(L.M014_CD_NCM,0)  = NVL(CODNBMSH,0) */THEN 'Cod. CEST do produto '||
                  B.SEQPRODUTO||' está divergente do cadastro no sistema - Abrir chamado para o Depto Cadastro Tributário - CEST XML: '||L.CODCEST||' - C5: '||E.CODCEST
                    -- WHEN NVL(L.CODCEST,0)  = NVL(E.CODCEST,0) AND NVL(L.M014_CD_NCM,0) != NVL(CODNBMSH,0)   THEN 'Codigo NCM do produto '||B.SEQPRODUTO||' está divergente do cadastro no sistema - Abrir chamado para o Depto Cadastro Tributário'
                       END AS MENSAGEM

  FROM CONSINCO.MLF_AUXNOTAFISCAL A INNER JOIN CONSINCO.MLF_AUXNFITEM B ON A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL
                                    INNER JOIN CONSINCO.MAP_PRODUTO C ON B.SEQPRODUTO = C.SEQPRODUTO
                                    INNER JOIN CONSINCO.MAP_FAMILIA E ON E.SEQFAMILIA = C.SEQFAMILIA
                                    INNER JOIN CONSINCO.MAP_FAMDIVISAO D ON D.SEQFAMILIA = E.SEQFAMILIA
                                    INNER JOIN TMP_M000_NF K ON (K.M000_NR_CHAVE_ACESSO = A.NFECHAVEACESSO)
                                    INNER JOIN TMP_M014_ITEM L ON (L.M000_ID_NF = K.M000_ID_NF AND L.M014_NR_ITEM = B.SEQITEMNFXML)

WHERE A.CODGERALOPER = 1
  AND L.M014_DM_TRIB_ICMS IN (1,9,8) -- De/Para na Function fc5_RetIndSituacaoNF_NFe - Regra Barra CST 10 70 60 respectivamente na clausula
                                     -- CST 202 e 500 (Simples Nacional) sera tratado no OR abaixo pois muda a regra
  AND (NVL(L.CODCEST,0) != NVL(E.CODCEST,1))-- OR NVL(L.M014_CD_NCM,0) != NVL(CODNBMSH,0))
  -- Trata SN
  OR A.CODGERALOPER = 1
 AND EXISTS(SELECT 1 FROM MAF_FORNECEDOR SN WHERE SN.MICROEMPRESA = 'S' AND SEQFORNECEDOR = A.SEQPESSOA)
 AND M014_CD_CFOP NOT IN (5401,5101,5102,6102)
 AND (NVL(L.CODCEST,0) != NVL(E.CODCEST,1))-- OR NVL(L.M014_CD_NCM,0) != NVL(CODNBMSH,0))*/

UNION ALL

-- Ticket 325855 - Solic Dublia - Adicionado em 05/12/2023 por Giuliano
-- Tratativa Uso/Cons da regra 58 - Trataamento entre Fornecedores e Grupo - Por Razao

SELECT DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                B.SEQAUXNFITEM AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                74 AS CODINCONSISTENC,
                'Item ' || B.SEQPRODUTO || ' está cadastrado com a Finalidade "Material de Uso e Consumo", portanto, só poderá ser lançado no CGO 02 (Fornec)' AS  MENSAGEM
  FROM CONSINCO.MLF_AUXNOTAFISCAL A INNER JOIN CONSINCO.MLF_AUXNFITEM B ON (A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL )
                                    INNER JOIN CONSINCO.MAP_PRODUTO C ON (C.SEQPRODUTO = B.SEQPRODUTO)
                                    INNER JOIN CONSINCO.MAP_FAMDIVISAO E ON (E.SEQFAMILIA = C.SEQFAMILIA)
  WHERE E.FINALIDADEFAMILIA = 'U'
  AND   A.CODGERALOPER != 2
  AND   A.SEQPESSOA > 999 -- Fornecedores fora Emp Grupo
  AND A.NROEMPRESA != 506
  AND A.CODGERALOPER NOT IN (14,652,128)

 UNION ALL

SELECT DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                B.SEQAUXNFITEM AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                75 AS CODINCONSISTENC,
                CASE WHEN A.CODGERALOPER = 59 AND (SELECT NAGF_BUSCACGCEMP(A.SEQPESSOA) FROM DUAL)  = (SELECT NAGF_BUSCACGCEMP(A.NROEMPRESA) FROM DUAL)
                  THEN 'Item ' || B.SEQPRODUTO || ' está cadastrado com a Finalidade "Material de Uso e Consumo", portanto, só poderá ser lançado no CGO 61 (Mesma Razão)'
                     WHEN A.CODGERALOPER = 61 AND (SELECT NAGF_BUSCACGCEMP(A.SEQPESSOA) FROM DUAL) != (SELECT NAGF_BUSCACGCEMP(A.NROEMPRESA) FROM DUAL)
                  THEN 'Item ' || B.SEQPRODUTO || ' está cadastrado com a Finalidade "Material de Uso e Consumo", portanto, só poderá ser lançado no CGO 59 (Razão Diferente)' END
                 MENSAGEM
  FROM CONSINCO.MLF_AUXNOTAFISCAL A INNER JOIN CONSINCO.MLF_AUXNFITEM B ON (A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL )
                                    INNER JOIN CONSINCO.MAP_PRODUTO C ON (C.SEQPRODUTO = B.SEQPRODUTO)
                                    INNER JOIN CONSINCO.MAP_FAMDIVISAO E ON (E.SEQFAMILIA = C.SEQFAMILIA)
  WHERE E.FINALIDADEFAMILIA = 'U'
  AND  (A.CODGERALOPER = 59 AND (SELECT NAGF_BUSCACGCEMP(A.SEQPESSOA) FROM DUAL)  = (SELECT NAGF_BUSCACGCEMP(A.NROEMPRESA) FROM DUAL)  -- 59 e Mesma Razao
    OR  A.CODGERALOPER = 61 AND (SELECT NAGF_BUSCACGCEMP(A.SEQPESSOA) FROM DUAL) != (SELECT NAGF_BUSCACGCEMP(A.NROEMPRESA) FROM DUAL)) -- 61 e Mesma Razao
  AND   A.SEQPESSOA < 999
  AND A.NROEMPRESA != 506
  AND A.CODGERALOPER NOT IN (14,652)

UNION ALL

-- Adicionado por Giuliano para tratar CodOrigem EX -17/01/24
-- PD EXIBE_ORIGEM_MERCADORIA

SELECT DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'B' AS BLOQAUTOR,
                76  AS CODINCONSISTENC,
                '(EX) Cod. Origem da Mercadoria Oriunda EX deve ser 1. PLU: '||B.SEQPRODUTO||' - Entrar em contato com Depto Cadastro Comercial' MENSAGEM

  FROM CONSINCO.MLF_AUXNOTAFISCAL A INNER JOIN CONSINCO.MLF_AUXNFITEM B ON A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL
                                    INNER JOIN CONSINCO.GE_PESSOA G ON G.SEQPESSOA = A.SEQPESSOA
                                    INNER JOIN CONSINCO.MAP_PRODUTO P ON P.SEQPRODUTO = B.SEQPRODUTO
                                    INNER JOIN CONSINCO.MAP_FAMDIVISAO F ON F.SEQFAMILIA = P.SEQFAMILIA
WHERE G.UF = 'EX'
  AND A.CODGERALOPER IN (43,5)
  AND F.CODORIGEMTRIB != 1 -- Olhar a tributacao da familia pois é o considerado na emissao

UNION ALL

-- Criado por Giuliano em 29/01/2024 - Solic Neides Ticket 341549
-- Barra Imp Ret Nulo ou Zerado com CST 60

SELECT DISTINCT (A.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                A.NUMERONF,
                A.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR, -- SOLICITAÇÃO SILENE 19/02/2024 TEAMSN
                77  AS CODINCONSISTENC,
                'O(s) Campo(s): '||
                CASE WHEN NVL(L.M014_VL_OP_PROP_DIST,0) = 0 THEN 'vICMSSubstituto' ELSE NULL END||
                CASE WHEN NVL(L.M014_VL_BC_ST_RET,0)    = 0 THEN ' vBCSTRet'       ELSE NULL END||
                CASE WHEN NVL(L.M014_VL_ICMS_ST_RET,0)  = 0 THEN ' vICMSSTRet'     ELSE NULL END||
                --CASE WHEN M014_VL_BC_FCP_RET   IS NULL THEN ' vBCFCPSTRet'    ELSE NULL END||
                --CASE WHEN M014_VL_FCP_RET      IS NULL THEN ' vFCPSTRet'      ELSE NULL END||
                ' do produto '||B.SEQPRODUTO||' esta(o) nulo(s) no XML! Entre em contato com o Departamento Fiscal'
                MENSAGEM

  FROM CONSINCO.MLF_AUXNOTAFISCAL A INNER JOIN CONSINCO.MLF_AUXNFITEM B ON A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL
                                    INNER JOIN CONSINCO.MAP_PRODUTO C ON B.SEQPRODUTO = C.SEQPRODUTO
                                    INNER JOIN CONSINCO.MAP_FAMILIA E ON E.SEQFAMILIA = C.SEQFAMILIA
                                    INNER JOIN CONSINCO.MAP_FAMDIVISAO D ON D.SEQFAMILIA = E.SEQFAMILIA
                                    INNER JOIN TMP_M000_NF K ON (K.M000_NR_CHAVE_ACESSO = A.NFECHAVEACESSO)
                                    INNER JOIN TMP_M014_ITEM L ON (L.M000_ID_NF = K.M000_ID_NF AND L.M014_NR_ITEM = B.SEQITEMNFXML)

WHERE A.CODGERALOPER = 1
  --AND A.NROEMPRESA IN (501,11,8,26,1,7,9,14,22,23,25,28,31,40,46) -- Solicitadas por Neides
  AND A.SEQPESSOA NOT IN (SELECT SEQPESSOA FROM GE_PESSOA G WHERE G.NROCGCCPF = 236433150110) -- Criar De/Para Posteriormente
  AND (L.M014_DM_TRIB_ICMS = 8 -- De/Para na Function fc5_RetIndSituacaoNF_NFe - Regra barra apenas CST 60
  -- Acrescentando SN - Ticket 421458 - Giuliano 22/07/2024
   OR EXISTS(SELECT 1 FROM MAF_FORNECEDOR SN WHERE SN.MICROEMPRESA = 'S' AND SEQFORNECEDOR = A.SEQPESSOA)
      AND M014_CD_CFOP NOT IN (5401,5101,5102,6102))
  -- Critérios que nao podem estar nulos
  AND (NVL(L.M014_VL_OP_PROP_DIST,0) = 0  -- vICMSSubstituto
   OR  NVL(L.M014_VL_BC_ST_RET,0)    = 0  -- vBCSTRet
   OR  NVL(L.M014_VL_ICMS_ST_RET,0)  = 0)  -- vICMSSTRet
 --OR  L.M014_VL_BC_FCP_RET   IS NULL  -- vBCFCPSTRet -- Removidos - Solic Neides
 --OR  L.M014_VL_FCP_RET      IS NULL) -- vFCPSTRet   -- ^

UNION ALL

-- Ticket 408539 | Adicionado por Giuliano em 11/06/24
-- Solic Silene Fiscal - Barrar data de entrada divergente nas notas de remessa amarradas

SELECT DISTINCT (X.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                X.NUMERONF,
                X.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'B' AS BLOQAUTOR,
                79  AS CODINCONSISTENC,
                'A data de entrada da NF está divergente da data de remessa amarrada! Data NF CGO '||X.CODGERALOPER||': '||TO_CHAR(X.DTAENTRADA, 'DD/MM/YYYY')||
                ' - CGO '||X2.CODGERALOPER||': '||TO_CHAR(X2.DTAENTRADA, 'DD/MM/YYYY')

  FROM MLF_AUXNOTAFISCAL X INNER JOIN CONSINCO.NAGV_NF_RELAC_REMESSA R ON X.SEQAUXNOTAFISCAL  = R.SEQAUX_O
                           INNER JOIN CONSINCO.MLF_AUXNOTAFISCAL X2    ON X2.SEQAUXNOTAFISCAL = R.SEQAUX_R
 WHERE 1=1
   AND X.DTAENTRADA != X2.DTAENTRADA
   AND X.CODGERALOPER IN (116,121)


UNION ALL

-- Ticket 415219 | Adicionado por Giuliano em 25/06/2024
-- Solic Simone Fiscal - Barrar Ean Trib nulo no XML e existente na C5

SELECT DISTINCT (X.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                X.NUMERONF,
                X.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'L' AS BLOQAUTOR,
                80  AS CODINCONSISTENC,
                'O Produto: '||B.SEQPRODUTO||' Está com a tag EAN Tributável NULA no XML!'||

                -- Removido pois quando tem vários eans ultrapassa os 250 caracteres da tabela de inconsistencias
                --LISTAGG(X2.CODACESSO, ', ')WITHIN GROUP(ORDER BY X2.SEQPRODUTO)||

                ' - Solicite a troca da nota. Dúvidas entrar em contato com o Depto Fiscal.' MSG

  FROM CONSINCO.MLF_AUXNOTAFISCAL X INNER JOIN CONSINCO.MLF_AUXNFITEM B ON X.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL
                                 INNER JOIN TMP_M000_NF K         ON K.M000_NR_CHAVE_ACESSO = X.NFECHAVEACESSO
                                 INNER JOIN TMP_M014_ITEM L       ON L.M000_ID_NF = K.M000_ID_NF  AND L.M014_NR_ITEM = B.SEQITEMNFXML
                                 INNER JOIN MAP_PRODCODIGO X2     ON X2.SEQPRODUTO = B.SEQPRODUTO
                                 INNER JOIN MAP_PRODUTO P         ON P.SEQPRODUTO = B.SEQPRODUTO
                                 INNER JOIN GE_PESSOA G           ON G.SEQPESSOA = X.SEQPESSOA
                                 INNER JOIN MAP_FAMDIVISAO FD     ON FD.SEQFAMILIA = P.SEQFAMILIA

WHERE 1=1
  AND NOT EXISTS (SELECT 1 FROM MAP_PRODCODIGO X
                   WHERE X.SEQPRODUTO = B.SEQPRODUTO
                   AND LPAD(X.CODACESSO,14,0) = LPAD(NVL(L.M014_CD_EAN_TRIB,0),14,0)
                   AND X.TIPCODIGO = 'E'
                   AND X.INDUTILVENDA = 'S')

  AND X.CODGERALOPER = 1
  AND X.SEQPESSOA > 999
  --AND A.DTAENTRADA BETWEEN :DT1 AND :DT2
  AND FD.FINALIDADEFAMILIA = 'R'
  AND X2.TIPCODIGO = 'E'
  AND X2.INDUTILVENDA = 'S'
  -- Inicialmente ira validar apenas a tag nula no XML
  AND X2.CODACESSO IS NOT NULL AND M014_CD_EAN_TRIB IS NULL
  --AND LPAD(X2.CODACESSO,14,0) != LPAD(NVL(L.M014_CD_EAN_TRIB,0),14,0)
  -- Inicialmente apenas 8 e 501
  --AND X.NROEMPRESA IN (501,8, 2,11,17,20,25,26,28,31,36,40,42,44) -- Ticket 424666 aplica em todas as empresas
  GROUP BY X.SEQAUXNOTAFISCAL, X.NUMERONF, X.NROEMPRESA, B.SEQPRODUTO
  
UNION ALL

-- Ticket 432832 - Adicionado por Giuliano em 29/07/2024
-- Regra para EX - Valida se o Pis/Cofins estão corretos

SELECT DISTINCT (X.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                X.NUMERONF,
                X.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'B' AS BLOQAUTOR,
                81  AS CODINCONSISTENC,
                '(EX) Aliquota de PIS/COFINS divergentes. Entrar em contato com Depto Cadastro Tributário'

  FROM MLF_AUXNOTAFISCAL X INNER JOIN MLF_AUXNFITEM XI ON X.SEQAUXNOTAFISCAL = XI.SEQAUXNOTAFISCAL
                           INNER JOIN MAP_PRODUTO XP ON XP.SEQPRODUTO = XI.SEQPRODUTO
                           INNER JOIN MAP_FAMDIVISAO FD ON FD.SEQFAMILIA = XP.SEQFAMILIA
                           INNER JOIN MAP_FAMFORNEC FC ON FC.SEQFAMILIA = XP.SEQFAMILIA
                           INNER JOIN MAP_TRIBUTACAOUF UF ON UF.NROTRIBUTACAO = FD.NROTRIBUTACAO
                           INNER JOIN MAF_FORNECEDOR F ON F.SEQFORNECEDOR = FC.SEQFORNECEDOR
                           INNER JOIN GE_PESSOA GE ON GE.SEQPESSOA = FC.SEQFORNECEDOR
       WHERE 1=1
       AND GE.UF = 'EX'
       AND UF.UFCLIENTEFORNEC = 'EX'
       AND (NVL(NULLIF(UF.PERPISDIF,0),1.65)    = 1.65 AND NVL(UF.SITUACAONFPIS,0) NOT IN (73,70)
         OR NVL(NULLIF(UF.PERCOFINSDIF,0),7.60) = 7.60  AND NVL(UF.SITUACAONFPIS,0) NOT IN (73,70))
       AND UF.NROREGTRIBUTACAO = 8 -- Importacao Direta
       AND UF.UFEMPRESA = 'SP'
       AND UF.TIPTRIBUTACAO = DECODE(NVL(FC.TIPFORNECEDORFAM,F.TIPFORNECEDOR) , 'I', 'EI', 'D', 'ED')
       AND X.CODGERALOPER IN (43,5)
       AND X.NROEMPRESA = 503
       
UNION ALL
       
-- Ticket 432832 - Adicionado por Giuliano em 29/07/2024
-- Regra para EX - Valida se a saída do IPI está parametrizada

SELECT DISTINCT (X.SEQAUXNOTAFISCAL) AS SEQAUXNOTAFISCAL,
                X.NUMERONF,
                X.NROEMPRESA,
                0   AS SEQAUXNFITEM,
                'B' AS BLOQAUTOR,
                82  AS CODINCONSISTENC,
                '(EX) Produto com entrada de IPI sem saída parametrizada. Entrar em contato com Depto Cadastro Comercial'

  FROM MLF_AUXNOTAFISCAL X INNER JOIN MLF_AUXNFITEM XI ON X.SEQAUXNOTAFISCAL = XI.SEQAUXNOTAFISCAL
                           INNER JOIN MAP_PRODUTO MP ON MP.SEQPRODUTO = XI.SEQPRODUTO
                           INNER JOIN MAP_FAMILIA MF ON MF.SEQFAMILIA = MP.SEQFAMILIA
                           INNER JOIN MAP_FAMFORNEC FC ON FC.SEQFAMILIA = MF.SEQFAMILIA
                           INNER JOIN GE_PESSOA GE ON GE.SEQPESSOA = FC.SEQFORNECEDOR
  WHERE 1=1
    AND UF = 'EX'
    AND NVL(MF.ALIQUOTAIPI,0) > 0
    AND (MF.PERISENTOIPI IS NULL
     OR MF.PEROUTROIPI IS NULL
     OR MF.PERALIQUOTAIPI IS NULL
     OR NVL(MF.PERBASEIPI,0) = 0)
    AND X.NROEMPRESA = 503

;
