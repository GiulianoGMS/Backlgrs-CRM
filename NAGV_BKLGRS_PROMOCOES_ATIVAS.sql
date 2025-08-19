CREATE OR REPLACE VIEW NAGV_BKLGRS_PROMOCOES_ATIVAS AS
SELECT DISTINCT B.SEQPRODUTO                                                                SKU,
                A.NROEMPRESA                                                                storeReference,
               'DescontoDePor Tabloide'                                                     Description,
                TO_CHAR(TO_DATE(B.DTAINICIOPROM, 'DD/MM/YY'), 'YYYY-MM-DD"T"HH24:MI:SS"Z"') startDateTime,
                TO_CHAR(TO_DATE(B.DTAFIMPROM, 'DD/MM/YY'),    'YYYY-MM-DD"T"HH24:MI:SS"Z"') endDateTime,
                DECODE(B.STATUS, 'A', 'TRUE', 'I', 'INACTIVE')                              isActive,
                B.PRECOPROMOCIONAL                                                          Price

  FROM CONSINCO.MRL_PROMOCAO A INNER JOIN CONSINCO.MRL_PROMOCAOITEM B ON A.SEQPROMOCAO = B.SEQPROMOCAO
                                                                     AND A.NROEMPRESA  = B.NROEMPRESA
                                                                     AND A.NROSEGMENTO = B.NROSEGMENTO
                                                                     AND A.CENTRALLOJA = B.CENTRALLOJA
                                                                     AND QTDEMBALAGEM  = 1

 WHERE B.QTDEMBALAGEM = 1
   AND A.CENTRALLOJA = 'M'
   AND TRUNC(SYSDATE) BETWEEN B.DTAINICIOPROM AND B.DTAFIMPROM

UNION ALL

-- Ativaveis

SELECT DISTINCT B.SEQPRODUTO                                                                SKU,
                E.NROEMPRESA                                                                storeReference,
               'DescontoDePor Ativavel'                                                     Description,
                TO_CHAR(TO_DATE(NVL(B.DTAVIGENCIAINI, A.DTAINICIO), 'DD/MM/YY'), 'YYYY-MM-DD"T"HH24:MI:SS"Z"') startDateTime,
                TO_CHAR(TO_DATE(NVL(B.DTAVIGENCIAFIM, A.DTAFIM), 'DD/MM/YY'),    'YYYY-MM-DD"T"HH24:MI:SS"Z"') endDateTime,
                DECODE('A', 'A', 'TRUE', 'I', 'INACTIVE')                                   isActive,
                B.PRECOPROMOCIONAL                                                          Price

  FROM CONSINCO.MRL_ENCARTE A INNER JOIN CONSINCO.MRL_ENCARTEPRODUTO B ON A.SEQENCARTE = B.SEQENCARTE
                              INNER JOIN CONSINCO.MAP_PRODUTO C        ON B.SEQPRODUTO = C.SEQPRODUTO
                              INNER JOIN MRL_ENCARTEEMP E ON E.SEQENCARTE = A.SEQENCARTE

 WHERE B.PRECOPROMOCIONAL > 0
   AND QTDEMBALAGEM = 1
   AND DESCRICAO LIKE 'MEU NAGUMO%'
   AND TRUNC(SYSDATE) BETWEEN NVL(B.DTAVIGENCIAINI, A.DTAINICIO) AND NVL(B.DTAVIGENCIAFIM, A.DTAFIM)

UNION ALL

-- Meu Nagumo

SELECT DISTINCT B.SEQPRODUTO                                                                SKU,
                A.CODLOJA                                                                   storeReference,
               'DescontoDePor MeuNagumo'                                                    Description,
                TO_CHAR(TO_DATE(A.DTINICIO, 'DD/MM/YY'),  'YYYY-MM-DD"T"HH24:MI:SS"Z"')     startDateTime,
                TO_CHAR(TO_DATE(A.DTFIM, 'DD/MM/YY'),    'YYYY-MM-DD"T"HH24:MI:SS"Z"')      endDateTime,
                DECODE('A', 'A', 'TRUE', 'I', 'INACTIVE')                                   isActive,
                A.PRECOPPROMOCIONAL                                                         Price

  FROM CONSINCO.NAGT_REMARCAPROMOCOES A INNER JOIN CONSINCO.MAP_PRODCODIGO B ON TO_CHAR(TO_NUMBER(a.CODIGOPRODUTO)) = B.CODACESSO
                                                                            AND B.TIPCODIGO IN ('B', 'E')

 WHERE 1=1
   AND a.TIPODESCONTO  = 4
   AND a.PROMOCAOLIVRE = 0
   AND TRUNC(SYSDATE) BETWEEN A.DTINICIO AND DTFIM

UNION ALL

-- Personalizada

SELECT DISTINCT B.SEQPRODUTO                                                                SKU,
                E.NROEMPRESA                                                                storeReference,
               'DescontoDePor Ativavel'                                                     Description,
                TO_CHAR(TO_DATE(NVL(B.DTAVIGENCIAINI, A.DTAINICIO), 'DD/MM/YY'), 'YYYY-MM-DD"T"HH24:MI:SS"Z"') startDateTime,
                TO_CHAR(TO_DATE(NVL(B.DTAVIGENCIAFIM, A.DTAFIM), 'DD/MM/YY'),    'YYYY-MM-DD"T"HH24:MI:SS"Z"') endDateTime,
                DECODE('A', 'A', 'TRUE', 'I', 'INACTIVE')                                   isActive,
                B.PRECOPROMOCIONAL                                                          Price

  FROM CONSINCO.MRL_ENCARTE A INNER JOIN CONSINCO.MRL_ENCARTEPRODUTO B ON A.SEQENCARTE = B.SEQENCARTE
                              INNER JOIN CONSINCO.MAP_PRODUTO C        ON B.SEQPRODUTO = C.SEQPRODUTO
                               LEFT JOIN MAX_EMPRESA E                 ON 1=1 AND E.NROEMPRESA < 300

 WHERE QTDEMBALAGEM = 1
   AND DESCRICAO LIKE 'MN PERSONALIZADA%'
   AND TRUNC(SYSDATE) BETWEEN NVL(B.DTAVIGENCIAINI, A.DTAINICIO) AND NVL(B.DTAVIGENCIAFIM, A.DTAFIM)
;
