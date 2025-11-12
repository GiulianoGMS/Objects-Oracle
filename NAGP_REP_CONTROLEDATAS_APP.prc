CREATE OR REPLACE PROCEDURE NAGP_REP_CONTROLEDATAS_APP AS

-- Criado por GIuliano em 12/11/2025
-- Replica os dados do banco DW do app para o ERP

 BEGIN
      
    FOR src IN (SELECT * FROM NAGV_BASE_MRL_PROMOCESPECIAL_APP X
                 WHERE NOT EXISTS (SELECT 1 FROM MRL_PROMOCESPECIALHIST B WHERE B.NROEMPRESA = X.NROEMPRESA
                                                                            AND X.PLU = B.SEQPRODUTO
                                                                            AND X.VLRPRECOPROMOC = B.VLRPRECOPROMOC
                                                                            AND X.QTDESOLICITADA = B.QTDESOLICITADA
                                                                            AND X.DTAINICIO = B.DTAINICIO
                                                                            AND X.DTAFIM = B.DTAFIM))
    LOOP

  INSERT INTO  MRL_PROMOCESPECIALHIST (
          SEQPROMOCESPECIAL,
          SEQPRODUTO,
          QTDEMBALAGEM,
          NROEMPRESA,
          CODACESSOESPECIAL,
          VLRPRECOPROMOC,
          QTDESOLICITADA,
          QTDEETIQEMITIDA,
          DTAINICIO,
          DTAFIM,
          STATUS,
          MOTIVOACAOPROMOC,
          DTAHORALTERACAO,
          USUALTERACAO,
          DTAHORAPROVACAO,
          USUAPROVACAO,
          MOTIVOREPROVA,
          INDLIBERACAO,
          USULIBERACAO,
          DTAHORALIBERACAO,
          INDEMIETIQUETA,
          SEQPROMOCESPECIALORIGEM,
          INDREPLICAFAMILIA,
          INDREPLICAASSOCIADO,
          INDREPLICARELACIONADO
  )
  VALUES (
          src.SEQPROMOCESPECIAL,
          src.PLU,
          src.QTDEMBALAGEM,
          src.NROEMPRESA,
          (SELECT NAG_GERA_EAN13_AUTO(src.NROEMPRESA) AS EAN FROM DUAL),
          src.VLRPRECOPROMOC,
          src.QTDESOLICITADA,
          src.QTDEETIQEMITIDA,
          src.DTAINICIO,
          src.DTAFIM,
          src.STATUS,
          src.MOTIVOACAOPROMOC,
          src.DTAHORALTERACAO,
          src.USUALTERACAO,
          src.DTAHORAPROVACAO,
          src.USUAPROVACAO,
          src.MOTIVOREPROVA,
          src.INDLIBERACAO,
          src.USULIBERACAO,
          src.DTAHORALIBERACAO,
          src.INDEMIETIQUETA,
          src.SEQPROMOCESPECIALORIGEM,
          src.INDREPLICAFAMILIA,
          src.INDREPLICAASSOCIADO,
          src.INDREPLICARELACIONADO
  );
  
  END LOOP;
  
 END;
