CREATE OR REPLACE VIEW NAGV_BKLGRS_PROMOCOES_ATIVAS_CRM AS
SELECT DISTINCT A.SEQENCARTE                                                                CODPROMOC,
                B.SEQPRODUTO                                                                SKU,
                E.NROEMPRESA                                                                storeReference,
               'DescontoDePor Personalizada'                                                     Description,
                TO_CHAR(TO_DATE(NVL(B.DTAVIGENCIAINI, A.DTAINICIO), 'DD/MM/YY'), 'YYYY-MM-DD"T"HH24:MI:SS"Z"') startDateTime,
                TO_CHAR(TO_DATE(NVL(B.DTAVIGENCIAFIM, A.DTAFIM), 'DD/MM/YY'),    'YYYY-MM-DD"T"HH24:MI:SS"Z"') endDateTime,
                DECODE('A', 'A', 'TRUE', 'I', 'INACTIVE')                                   isActive,
                B.PRECOPROMOCIONAL                                                          Price

  FROM CONSINCO.MRL_ENCARTE A INNER JOIN CONSINCO.MRL_ENCARTEPRODUTO B ON A.SEQENCARTE = B.SEQENCARTE
                              INNER JOIN CONSINCO.MAP_PRODUTO C        ON B.SEQPRODUTO = C.SEQPRODUTO
                              INNER JOIN CONSINCO.MRL_ENCARTEEMP E     ON E.SEQENCARTE = A.SEQENCARTE

 WHERE QTDEMBALAGEM = 1
   AND (DESCRICAO LIKE 'CRM PERSONALIZADA%' and 1=1 OR A.SEQGRUPOPROMOC = 11)
   AND TRUNC(SYSDATE) BETWEEN NVL(B.DTAVIGENCIAINI, A.DTAINICIO) AND NVL(B.DTAVIGENCIAFIM, A.DTAFIM);
