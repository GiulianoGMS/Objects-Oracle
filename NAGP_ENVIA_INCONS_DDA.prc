CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_ENVIA_INCONS_DDA AS

BEGIN
  
    FOR t IN (SELECT DISTINCT F.SEQPESSOA FROM CONSINCO.FI_TITULO F INNER JOIN CONSINCO.FI_ESPECIE FI      ON F.CODESPECIE = FI.CODESPECIE AND F.NROEMPRESAMAE = FI.NROEMPRESAMAE
                                                                    INNER JOIN CONSINCO.GE_PESSOA  GE      ON F.SEQPESSOA  = GE.SEQPESSOA  
                                                                    INNER JOIN CONSINCO.FI_COMPLTITULO  FC ON F.SEQTITULO  = FC.SEQTITULO
                                   
                WHERE F.OBRIGDIREITO     = 'O'

                  -- Especies filtradas Solic Simone
                  
                  AND F.CODESPECIE NOT IN ('13SAL','ADIEMP','ADIPRP','ADISAL','ANTREC','ATIPCO','ATIVOC','BONIAC','BONIDV','CHQPG','DEVCOM','DEVPAG','DEVPCO',
                       'DUPCIM','DUPPCO','DUPPCX','DVRBEC','EMPAG','EMPAIM','FATNAG','FERIAS','FINAIM','FINANC','LEIROU','ORDSAL','PAGEST','PENSAO',
                       'RECARG','REEMB','RESCIS','VLDESC','COFINS','CONTDV','DSSLL','FGTS','FGTSQT','ICMS','IMPOST','INSS','INSSNF','INSTANG','IPI',
                       'IR','IRRFFP','IRRFNF','ISSQN','ISSQNP','ISSST','LEASIM','LEASIN','PCCNF','PIS','PROTRA','ALUGPG','FATICD', 'QTPRP','ADIPPG',
                       'DESP','ATVEFU','ATIVOC','ATIVO')
                       
                  -- Fornec Excluidos por serem depositos
                  
                  AND GE.NOMERAZAO NOT LIKE '%PEPSICO%'
                  AND GE.NOMERAZAO NOT LIKE '%LOUIS DREYFUS%'
                  AND GE.NOMERAZAO NOT LIKE '%DANONE%'
                  
                  -- Filtros padrões da view
                  
                  AND F.ABERTOQUITADO    = 'A' 
                  AND FI.TIPOESPECIE     = 'T' 
                  AND F.SITUACAO        != 'S'  
                  AND NVL(F.SUSPLIB,'L') = 'L'
                  AND FC.CODBARRA       IS NULL     
                  AND FC.CODBARRA       IS NULL

                  -- Prazo Solic Simone
                  
                  AND F.DTAVENCIMENTO BETWEEN TRUNC(SYSDATE) AND SYSDATE + 5
                  )
                  
     LOOP
      
     BEGIN
       CONSINCO.NAGP_INCONS_DDA_FIN_03(T.SEQPESSOA);
       
       END;
       
     END LOOP;
       
 END;
