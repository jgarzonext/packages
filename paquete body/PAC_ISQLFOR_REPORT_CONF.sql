--------------------------------------------------------
--  DDL for Package Body PAC_ISQLFOR_REPORT_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_ISQLFOR_REPORT_CONF" AS

/******************************************************************************
   NOMBRE:      pac_isqlfor_report_conf
   PROP¿SITO: Nuevo package con las funciones que se utilizan en las impresiones en reportes.
   En este package principalmente se utilizar¿ para funciones de validaci¿n de si un documento se imprime o no.

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
    1.0        18/03/2015   FFO                1. CREACION
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

	FUNCTION f_factu_intermedi (
			pcagente	IN	NUMBER,
			pcempres	IN	NUMBER,
			pffecmov	IN	DATE,
			ptipo	IN	NUMBER
	) RETURN VARCHAR2
	IS
	  CURSOR c_ctates IS
	    SELECT cagente,cconcta,iimport,tdescrip,nrecibo,sseguro,fvalor,sproces
	      FROM ctactes
	     WHERE cagente=pcagente AND
	           cempres=pcempres AND
	           to_date(fvalor, 'dd/mm/yy')=to_date(pffecmov, 'dd/mm/yy');

	  vreturn VARCHAR2(1000);
	  vsuma   FLOAT:=0;

	BEGIN
	    IF ptipo=1 THEN
	      FOR cta IN c_ctates LOOP
	          vreturn:=vreturn
	                   || cta.tdescrip
	                   || '<br>';
	      END LOOP;
	    ELSIF ptipo=2 THEN
	      FOR cta IN c_ctates LOOP
	          vreturn:=vreturn
	                   || to_char(cta.iimport, 'FM999G999G990D90')
	                   || '<br>';
	      END LOOP;
	    ELSIF ptipo=3 THEN
	      FOR cta IN c_ctates LOOP
	          vsuma:=vsuma+cta.iimport;
	      END LOOP;

	      vreturn:=to_char(vsuma, 'FM999G999G990D90');
	    END IF;

	    RETURN vreturn;
	EXCEPTION
	  WHEN OTHERS THEN
	             CLOSE c_ctates;

	             RETURN NULL;

	END f_factu_intermedi;

   FUNCTION f_jrep_trad(pentrada IN VARCHAR2)
      RETURN VARCHAR2 IS
   BEGIN
      IF pentrada IS NULL THEN
         RETURN NULL;   -- para que funcionen los NVLS
      END IF;

      RETURN REPLACE(REPLACE('"' || REPLACE(pentrada, CHR(34), CHR(39)) || '"', '\par "', '"'),
                     '\par ', CHR(10));
   END f_jrep_trad;

    FUNCTION f_intermediarios(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcolumn IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      vret           VARCHAR2(2000);
      vcagente       NUMBER;
   BEGIN
      vret := NULL;

      IF NVL(pmodo, 'POL') = 'EST' THEN
         FOR i IN (SELECT   cagente, pac_isqlfor.f_agente(cagente) tagente,
                            pac_isqlfor.f_telefono(cagente) telf, ppartici || '%' porc_part
                       FROM estage_corretaje
                      WHERE sseguro = psseguro
                        AND nmovimi = (SELECT MAX(nmovimi)
                                         FROM estage_corretaje
                                        WHERE sseguro = psseguro
                                          AND nmovimi <= pnmovimi)
                   ORDER BY islider DESC, cagente) LOOP
            IF pcolumn = 1 THEN
               vret := vret || i.cagente || ' \par ';
            ELSIF pcolumn = 2 THEN
               vret := vret || i.tagente || ' \par ';
            ELSIF pcolumn = 3 THEN
               vret := vret || i.telf || ' \par ';
            ELSIF pcolumn = 4 THEN
               vret := vret || i.porc_part || ' \par ';
            END IF;
         END LOOP;

         IF vret IS NULL THEN
            SELECT cagente
              INTO vcagente
              FROM estseguros
             WHERE sseguro = psseguro;

            IF pcolumn = 1 THEN
               vret := vcagente;
            ELSIF pcolumn = 2 THEN
               vret := pac_isqlfor.f_agente(vcagente);
            ELSIF pcolumn = 3 THEN
               vret := pac_isqlfor.f_telefono(vcagente);
            ELSIF pcolumn = 4 THEN
               vret := '100%';
            END IF;
         END IF;
      ELSE
         FOR i IN (SELECT   cagente, pac_isqlfor.f_agente(cagente) tagente,
                            pac_isqlfor.f_telefono(cagente) telf, ppartici || '%' porc_part
                       FROM age_corretaje
                      WHERE sseguro = psseguro
                        AND nmovimi = (SELECT MAX(nmovimi)
                                         FROM age_corretaje
                                        WHERE sseguro = psseguro
                                          AND nmovimi <= pnmovimi)
                   ORDER BY islider DESC, cagente) LOOP
            IF pcolumn = 1 THEN
               vret := vret || i.cagente || ' \par ';
            ELSIF pcolumn = 2 THEN
               vret := vret || i.tagente || ' \par ';
            ELSIF pcolumn = 3 THEN
               vret := vret || i.telf || ' \par ';
            ELSIF pcolumn = 4 THEN
               vret := vret || i.porc_part || ' \par ';
            END IF;
         END LOOP;

         IF vret IS NULL THEN
            SELECT cagente
              INTO vcagente
              FROM seguros
             WHERE sseguro = psseguro;

            IF pcolumn = 1 THEN
               vret := vcagente;
            ELSIF pcolumn = 2 THEN
               vret := pac_isqlfor.f_agente(vcagente);

               IF (vret IS NULL)
                  AND(vcagente IS NOT NULL) THEN
                  SELECT pac_isqlfor.f_persona(psseguro, 1, sperson)
                    INTO vret
                    FROM agentes
                   WHERE cagente = vcagente;
               END IF;
            ELSIF pcolumn = 3 THEN
               vret := pac_isqlfor.f_telefono(vcagente);
            ELSIF pcolumn = 4 THEN
               vret := '100%';
            END IF;
         END IF;
      END IF;

      RETURN f_jrep_trad(vret);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN '';
   END f_intermediarios;

   /******************************************************************************
   NOMBRE:      f_numero_persona_rel
   PROP¿SITO:odtener datos de personas relacionadas que sean socios consorcio


   pdato: dato a odtener
        1 nombre
        2 nit

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
    1.0        01/02/2017   FFO                1. CREACION
******************************************************************************/
  FUNCTION f_numero_persona_rel (
    pdato   	IN    NUMBER,
    vsperson  IN    NUMBER,
    vnumero  IN    NUMBER DEFAULT 1
	)  RETURN VARCHAR2 IS

  CURSOR c_personas_rel IS
        SELECT * FROM (
              SELECT rownum  fila, ppr.SPERSON_REL FROM per_personas_rel ppr
              WHERE ppr.CTIPPER_REL = 4
                AND ppr.SPERSON = vsperson) x
              WHERE x.fila = vnumero;

        vreturn VARCHAR2(2000);
  BEGIN
    IF pdato = 1 THEN
      FOR per IN c_personas_rel LOOP
              vreturn := pac_isqlfor.f_persona(null, null, per.sperson_rel);
      END LOOP;
    ELSIF pdato = 2 THEN
      FOR per IN c_personas_rel LOOP
              vreturn := pac_isqlfor.f_dni(null, null, per.sperson_rel);
      END LOOP;
    END IF;

    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END  f_numero_persona_rel;

END pac_isqlfor_report_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_ISQLFOR_REPORT_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ISQLFOR_REPORT_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ISQLFOR_REPORT_CONF" TO "PROGRAMADORESCSI";
