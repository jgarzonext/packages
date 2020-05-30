CREATE OR REPLACE PACKAGE BODY PAC_ISQLFOR_CONF AS

/******************************************************************************
   NOMBRE:      pac_impresion_CONF
   PROPSITO: Nuevo package con las funciones que se utilizan en las impresiones.
   En este package principalmente se utilizar para funciones de validacin de si un documento se imprime o no.

   REVISIONES:
   Ver        Fecha        Autor             Descripcin
   ---------  ----------  ---------------  ------------------------------------
    1.0        18/03/2015   FFO                1. CREACION
    2.0        12/02/2019   AABC               2. TC464 SPERSON_DEUD, SPERSON_ACRE   
    3.0        05/03/2019   DFR                3. IAXIS-2018: Ficha financiera intermediario
    4.0        14/03/2019   ACL                4. TCS_309: Se agrega funciones
    5.0        18/03/2019   ACL                5. TCS_309: Se agrega funcion f_letras_plazo
    6.0        20/03/2019   ACL                6. TCS_19: Se crea la funciÃ¯Â¿Â½n f_intermediario
    7.0        21/03/2019   ACL                7. TCS_19: Se crea funciones para codeudor
    8.0        22/03/2019   Swapnil            8. Cambios de IAXIS-3286 
    9.0        28/03/2019   ACL                9. IAXIS-2136 Se crean funciones para la caratula de poliza
    10.0       03/04/2019   ACL                10. IAXIS-2136 Se crean funciones para traer los datos del beneficiario
    11.0       05/04/2019   ACL                11. IAXIS-2136 Se crean funciones para producto caucion judicial
    12.0       11/04/2019   ECP                12. IAXIS-2122: Reporte de anlisis en InglÃ¯Â¿Â½s    
    13.0       23/04/2019   ACL                13. IAXIS-2136 Ajustes a las funciones f_texto_clausula y f_trm_caratula
    14.0       06/05/2019   ACL                14. IAXIS-2136 Se ajusta la función f_texto_clausula y se crean las funciones f_tex_clausulado y f_texto_exclusion
    15.0       09/05/2019   ACL                15. IAXIS-2136 Se agrega la función f_valor_iva_pesos
    16.0       10/05/2019   ACL                13. IAXIS-3656 Se crean las funciones f_tip_movim y f_delega
    17.0       14/05/2019   RABQ               16. IAXIS-3750 Creación función indicadores para reporte USF
    18.0       14/05/2019   ACL                17. IAXIS-2136 Se crea la funcion f_agente_new. Se ajusta f_texto_exclusion
    19.0       26/07/2018   KK                 19. IAXIS-3152:Ficha financiera intermediario - Verificación datos 
    20.0       09/09/2019   JLTS               20. IAXIS-5154: Se ajusta la función f_get_sfinanci
    21.0       12/09/2019   IRDR               21. IAXIS-2568: Se ajustan las funciones f_tex_clausulado, f_texto_clausula, f_texto_exclusion_rc
    22.0       10/10/2019   ECP                22. IAXIS-4082 Convenio Grandes Beneficiarios - RCE Derivado de Contratos
    23.0       12/12/2019   ECP                23. IAXIS-4785. Cumulo Depurado y ajustes a pantalla axisrea052
    24.0       10/02/2020   JLTS               24. IAXIS-2122. Ajuste de la función f_get_ficha incluyendo una nueva opción de extraer la fecha en formato DD/MM/YYYY
	25.0       10/03/2020   JLTS               25. IAXIS-2138. Se crea la funcion f_texto_clau_caratula para consulta de clausulas de una poliza
    26.0       21/05/2020   ECP                26. IAXIS-7791. Ficha T�cnica
	
	
	
	
	
	
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

  FUNCTION f_factu_intermedi (
      pcagente  IN  NUMBER,
      pcempres  IN  NUMBER,
      pffecmov  IN  DATE,
      ptipo IN  NUMBER
  ) RETURN VARCHAR2
  IS
    CURSOR c_ctates IS
            SELECT cagente,cconcta, -- BUG 1896 AP 23/04/2018
          (select tcconcta from desctactes where cconcta = c.cconcta and cidioma = 8) tcconcta,
           sum(decode(cdebhab,1,iimport,2,-iimport)) iimport,
           fvalor,
           sproces
        FROM ctactes c
       WHERE cagente=pcagente AND
             cempres=pcempres and
             to_date(fvalor, 'dd/mm/yy')=to_date(pffecmov, 'dd/mm/yy')
             and iimport <> 0
             and cconcta in (53,54,55,56)
       and sproces = (select max (sproces)from ctactes where cagente=pcagente and cempres=pcempres and to_date(fvalor, 'dd/mm/yy')=to_date(pffecmov, 'dd/mm/yy')
                     and iimport <> 0 and cconcta in (53,54,55,56))
             group by cagente,cconcta,fvalor,sproces
    UNION
        select cagente,1,
                  'Valor operaciÃ¯Â¿Â½n' tcconcta,
                   sum(decode(cdebhab,1,iimport,2,-iimport)) iimport,
                   fvalor,
                   sproces
                FROM ctactes c
               WHERE cagente=pcagente AND
                     cempres=pcempres and
                     to_date(fvalor, 'dd/mm/yy')=to_date(pffecmov, 'dd/mm/yy')
                     and iimport <> 0
                     AND cconcta NOT IN (53,54,55,56,98)
           and sproces = (select max (sproces)from ctactes where cagente=pcagente and cempres=pcempres and to_date(fvalor, 'dd/mm/yy')=to_date(pffecmov, 'dd/mm/yy')
                     and iimport <> 0 and cconcta not in (53,54,55,56,98))
                     group by cagente,1,fvalor,sproces
     UNION
        select cagente,cconcta,
          (select tcconcta from desctactes where cconcta = c.cconcta and cidioma = 8) tcconcta,
                   sum(decode(cdebhab,1,iimport,2,iimport)) iimport,
                   fvalor,
                   sproces
                FROM ctactes c
               WHERE cagente=pcagente AND
                     cempres=pcempres and
                     to_date(fvalor, 'dd/mm/yy')=to_date(pffecmov, 'dd/mm/yy')
                     and iimport <> 0
                     and cconcta = 98
           and sproces = (select max (sproces)from ctactes where cagente=pcagente and cempres=pcempres and to_date(fvalor, 'dd/mm/yy')=to_date(pffecmov, 'dd/mm/yy'))
                     group by cdebhab, cagente,cconcta,fvalor,sproces
                     order by iimport desc;  -- BUG 1896 AP 23/04/2018

    vreturn VARCHAR2(1000);
    vsuma   FLOAT:=0;

  BEGIN
      IF ptipo=1 THEN
        FOR cta IN c_ctates LOOP
         if cta.cconcta <> '98' then
          if cta.cconcta = '99' then
           vreturn:=vreturn
                     || 'Valor de la operaciÃ¯Â¿Â½n'
                     || '<br>';
          else
            vreturn:=vreturn
                     || cta.tcconcta
                     || '<br>';
                     end if;
           end if;
        END LOOP;
      ELSIF ptipo=2 THEN
        FOR cta IN c_ctates LOOP
        if cta.cconcta <> '98' then
            vreturn:=vreturn
                     || to_char(cta.iimport, 'FM999G999G999G999G990D90')
                     || '<br>';
                     end if;
        END LOOP;
      ELSIF ptipo=3 THEN
        FOR cta IN c_ctates LOOP
               if cta.cconcta = '98' then
           -- vreturn:=vreturn BUG 1896 AP 23/04/2018
            vreturn:= to_char(cta.iimport, 'FM999G999G999G999G990D90') ;

                     end if;

        END LOOP;


      END IF;

      RETURN vreturn;
  EXCEPTION
    WHEN OTHERS THEN
               CLOSE c_ctates;

               RETURN NULL;

  END f_factu_intermedi;

  /******************************************************************************
   NOMBRE:      f_per_relacionadas
   PROPÃ¯Â¿Â½SITO:odtener datos de personas relacionadas

   ptipo: tipo de perona relacionada,
        1 Representante legal
        2 Sede
        3 Miembro consorcio

   pdato: dato a odtener
        1 nombre
        2 nit
        3 direccion

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ¯Â¿Â½n
   ---------  ----------  ---------------  ------------------------------------
    1.0        06/07/2016   FFO                1. CREACION
******************************************************************************/

  FUNCTION f_per_relacionadas (
    ptipo     IN      NUMBER,
    pdato     IN      NUMBER,
    pagente   IN      NUMBER
  )  RETURN VARCHAR2
  IS

  CURSOR c_personas_rel IS
        SELECT R.SPERSON_REL, R.TLIMITA FROM PER_PERSONAS_REL R, AGENTES A
                                        WHERE R.SPERSON = A.SPERSON
                                        AND R.CTIPPER_REL = ptipo
                                        AND A.CAGENTE = pagente;
        vreturn VARCHAR2(2000);
  BEGIN
    IF pdato = 1 THEN
      FOR persona IN c_personas_rel LOOP
              vreturn:=vreturn
                       || pac_isqlfor.f_persona(null, null, persona.sperson_rel)
                       || '<br>';
      END LOOP;
    ELSIF pdato = 2 THEN
      FOR persona IN c_personas_rel LOOP
              vreturn:=vreturn
                       || pac_isqlfor.f_dni(null, null, persona.sperson_rel)
                       || '<br>';
      END LOOP;
    ELSIF pdato = 3 THEN
      FOR persona IN c_personas_rel LOOP
              vreturn:=vreturn
                       || pac_isqlfor.f_direccion(persona.sperson_rel, 1)
                       || '<br>';
      END LOOP;
    ELSIF pdato = 4 THEN
      FOR persona IN c_personas_rel LOOP
              vreturn:=vreturn
                       || persona.TLIMITA
                       || '<br>';
      END LOOP;
    END IF;

    RETURN nvl(vreturn, ' ');
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_per_relacionadas;

/******************************************************************************
   NOMBRE:      f_per_socios
   PROPÃ¯Â¿Â½SITO:odtener datos de personas relacionadas que sean socios


   pdato: dato a odtener
        1 nombre
        2 nit
        3 direccion

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ¯Â¿Â½n
   ---------  ----------  ---------------  ------------------------------------
    1.0        06/07/2016   FFO                1. CREACION
******************************************************************************/
  FUNCTION f_per_socios (
    pdato     IN      NUMBER,
    pagente   IN      NUMBER
  )  RETURN VARCHAR2 IS

  CURSOR c_personas_rel IS
        SELECT R.SPERSON_REL FROM PER_PERSONAS_REL R, AGENTES A, PER_PERSONAS P
                                        WHERE R.SPERSON = A.SPERSON
                                        AND P.SPERSON = A.SPERSON
                                        AND A.CAGENTE = pagente
                                        AND P.CTIPPER = 2;
        vreturn VARCHAR2(2000);
  BEGIN
    IF pdato = 1 THEN
      FOR persona IN c_personas_rel LOOP
              vreturn:=vreturn
                       || pac_isqlfor.f_persona(null, null, persona.sperson_rel)
                       || '<br>';
      END LOOP;
    ELSIF pdato = 2 THEN
      FOR persona IN c_personas_rel LOOP
              vreturn:=vreturn
                       || pac_isqlfor.f_dni(null, null, persona.sperson_rel)
                       || '<br>';
      END LOOP;
    ELSIF pdato = 3 THEN
      FOR persona IN c_personas_rel LOOP
              vreturn:=vreturn
                       || pac_isqlfor.f_direccion(persona.sperson_rel, 1)
                       || '<br>';
      END LOOP;
    END IF;

    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_per_socios;

  /******************************************************************************
   NOMBRE:      f_get_sucursal
   PROPÃ¯Â¿Â½SITO:octener el cosigo o nombre de la sucursar de un agente


   pdato: dato a odtener
        1 ptipo
        2 pcagente


   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ¯Â¿Â½n
   ---------  ----------  ---------------  ------------------------------------
    1.0        10/25/2016   FFO                1. CREACION
******************************************************************************/
  FUNCTION f_get_sucursal (
    ptipo     IN      NUMBER,
    pcagente    IN      NUMBER
  )  RETURN VARCHAR2 IS

  CURSOR c_padre IS
        SELECT r.cpadre, a.ctipage  FROM redcomercial r, agentes a WHERE r.cagente = pcagente  AND r.cempres = 24 AND a.cagente = r.cpadre;
        vreturn VARCHAR2(2000);
  BEGIN
    IF ptipo = 1 THEN
      FOR padre IN c_padre LOOP
          IF padre.ctipage = 2 THEN
              vreturn:=vreturn
                       || padre.cpadre
                       || '<br>';
          ELSE
              vreturn:=vreturn
                       || f_get_sucursal(ptipo, padre.cpadre)
                       || '<br>';
          END IF;
      END LOOP;
    ELSIF ptipo = 2 THEN
      FOR padre IN c_padre LOOP
          IF padre.ctipage = 2 THEN
              vreturn:=vreturn
                       || pac_isqlfor.f_agente(padre.cpadre)
                       || '<br>';
          ELSE
              vreturn:=vreturn
                       || f_get_sucursal(ptipo, padre.cpadre)
                       || '<br>';
          END IF;
      END LOOP;
    END IF;

    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_get_sucursal;

  /******************************************************************************
   NOMBRE:      f_per_socios_cons
   PROPÃ¯Â¿Â½SITO:odtener datos de personas relacionadas que sean socios consorcio


   pdato: dato a odtener
        1 nombre
        2 nit
        3 direccion
        4 %part
        5 mail
        6 tel
        7 ciudad

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ¯Â¿Â½n
   ---------  ----------  ---------------  ------------------------------------
    1.0        06/07/2016   FFO                1. CREACION
******************************************************************************/
  FUNCTION f_per_socios_cons (
   pdato     IN      NUMBER,
    vseguro    IN      NUMBER,
    vcdomici  IN    NUMBER DEFAULT 1
  )  RETURN VARCHAR2 IS

  CURSOR c_personas_rel IS
        SELECT ppr.sperson_rel, ppr.pparticipacion FROM per_personas_rel ppr, tomadores tm where
        ppr.sperson = tm.sperson
        and ppr.cagrupa = tm.cagrupa
        and CTIPPER_REL=0
        and tm.sseguro =vseguro;

        vreturn VARCHAR2(2000);
  BEGIN
    IF pdato = 1 THEN
      FOR per IN c_personas_rel LOOP
              vreturn:=vreturn
                       || pac_isqlfor.f_persona(null, null, per.sperson_rel)
                       || '<br>';
      END LOOP;
    ELSIF pdato = 2 THEN
      FOR per IN c_personas_rel LOOP
              vreturn:=vreturn
                       || pac_isqlfor.f_dni(null, null, per.sperson_rel)
                       || '<br>';
      END LOOP;
    ELSIF pdato = 3 THEN
      FOR per IN c_personas_rel LOOP
              vreturn:=vreturn
                       || pac_isqlfor.f_direccion(per.sperson_rel, 1)
                       || '<br>';
      END LOOP;
    ELSIF pdato = 4 THEN
      FOR per IN c_personas_rel LOOP
              vreturn:=vreturn
                       || per.pparticipacion||'%'
                       || '<br>';
      END LOOP;
    ELSIF pdato = 5 THEN
      FOR per IN c_personas_rel LOOP
              vreturn:=vreturn
                       || nvl(pac_isqlfor.f_per_contactos(per.sperson_rel, 3),' ')
                       || '<br>';
      END LOOP;
    ELSIF pdato = 6 THEN
      FOR per IN c_personas_rel LOOP
              vreturn:=vreturn
                       || nvl(pac_isqlfor.f_telefono(per.sperson_rel), ' ')
                       || '<br>';
      END LOOP;
    ELSIF pdato = 7 THEN
      FOR per IN c_personas_rel LOOP
              vreturn:=vreturn
                       ||nvl(pac_isqlfor.f_provincia(per.sperson_rel, nvl(vcdomici, 1)),' ')
                       || '<br>';
      END LOOP;
    END IF;

    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_per_socios_cons;

   /*************************************************************************
      FUNCTION f_garantias_contratadas
      FunciÃ¯Â¿Â½n que se utilizarÃ¯Â¿Â½ para obtener los datos de las garantÃ¯Â¿Â½as contratadas en un convenio,su capital asegurado, carencia, franquicia, limite prestaciÃ¯Â¿Â½n y RevalorizaciÃ¯Â¿Â½n.
      param in P_SSEGURO    : NÃ¯Â¿Â½mero de seguro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 Ã¯Â¿Â½ 1er Columna desc. de garantÃ¯Â¿Â½as,  textos 2- 2Ã¯Â¿Â½ columna,Capitales asegurados, primas,etc
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_garantias_contratadas(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2 IS
      t_moneda         VARCHAR2(10);

    CURSOR c_garanseg IS
        SELECT gs.cgarant, gg.tgarant, gs.finivig finiefe , gs.ffinvig ffinefe, gs.icapital, gs.sseguro, d.impmin
              FROM garanseg gs, garangen gg, (SELECT s.sseguro, p.cgarant, s.impmin, s.nriesgo, s.finiefe, s.nmovimi
                                              FROM bf_bonfranseg s, bf_progarangrup p
                                              WHERE s.cgrup = p.codgrup
                                              AND  s.nmovimi = (SELECT  MAX(nmovimi)
                                                                                  FROM bf_bonfranseg
                                                                                     WHERE sseguro = s.sseguro)) d
              WHERE d.sseguro(+) = gs.sseguro
              AND d.cgarant(+) = gs.cgarant
              AND d.nriesgo(+) = gs.nriesgo
              AND d.nriesgo(+) = gs.nriesgo
              AND d.nmovimi(+) = gs.nmovimi
              AND gg.cidioma = p_cidioma
              AND gg.cgarant = gs.cgarant
              AND gs.sseguro in (select sseguro from sin_siniestro)
              AND gs.nmovimi = (SELECT MAX(nmovimi)
                                                FROM garanseg
                                               WHERE sseguro = gs.sseguro)
              AND gs.sseguro = p_sseguro
        GROUP BY (gs.cgarant, gg.tgarant, gs.finivig, gs.ffinvig, gs.icapital, gs.sseguro, d.impmin)  ORDER BY gs.cgarant;

    vicapital NUMBER := 0;
    vreturn VARCHAR2(2000);
  BEGIN
    BEGIN 
        SELECT pac_monedas.f_cmoneda_t(p.cdivisa) INTO t_moneda  FROM productos p, seguros s 
        WHERE  s.sseguro = p_sseguro   AND p.sproduc = s.sproduc;
         
        EXCEPTION
      WHEN OTHERS THEN
       t_moneda:='COP';
    END;

   IF p_tipo = 1 THEN
      FOR gara IN c_garanseg LOOP
               vreturn := vreturn || RPAD(gara.cgarant || ' ' || gara.tgarant, 60) || '<br>';
      END LOOP;
   ELSIF p_tipo = 2 THEN
      FOR gara IN c_garanseg LOOP
               vreturn := vreturn || gara.finiefe|| '<br>';
      END LOOP;
   ELSIF p_tipo = 3 THEN
      FOR gara IN c_garanseg LOOP
               vreturn := vreturn || gara.ffinefe || '<br>';
      END LOOP;
   ELSIF p_tipo = 4 THEN
      FOR gara IN c_garanseg LOOP
               vreturn := vreturn || nvl(TO_CHAR(gara.icapital, 'FM999G999G999G999G990D90'), 0)  || t_moneda ||'<br>';
      END LOOP;
   ELSIF p_tipo = 5 THEN
      FOR gara IN c_garanseg LOOP
                   vreturn := vreturn || nvl(TO_CHAR(gara.impmin, 'FM999G999G999G999G990D90'), 0)  || t_moneda || '<br>';
      END LOOP;
   ELSIF p_tipo = 6 THEN
      FOR gara IN c_garanseg LOOP
                   vicapital := vicapital + gara.icapital;
      END LOOP;

      vreturn := nvl(TO_CHAR(vicapital, 'FM999G999G999G999G990D90'), 0)||' '|| t_moneda ;
   END IF;

    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_garantias_contratadas;


     /*************************************************************************
      FUNCTION f_get_contratragarantias
      FunciÃ¯Â¿Â½n que se utilizarÃ¯Â¿Â½ para obtener los datos de las garantÃ¯Â¿Â½as contratadas en un convenio,su capital asegurado, carencia, franquicia, limite prestaciÃ¯Â¿Â½n y RevalorizaciÃ¯Â¿Â½n.
      param in P_SSEGURO    : NÃ¯Â¿Â½mero de seguro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 Ã¯Â¿Â½ 1er Columna desc. de garantÃ¯Â¿Â½as,  textos 2- 2Ã¯Â¿Â½ columna,Capitales asegurados, primas,etc
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_get_contratragarantias(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2 IS

    CURSOR c_ctgar IS
        SELECT DISTINCT(ctc.nradica),
       ff_desvalorfijo(8001035, p_cidioma, ctc.ctipo) ctipo,
       ff_desvalorfijo(8001037, p_cidioma, ctc.ctenedor) corigen,
       ff_desvalorfijo(8001038, p_cidioma, ctc.cestado) cestado,
       pac_isqlfor.f_dades_persona(pc.sperson, 1, 8) nif,
       pac_isqlfor.f_persona(null, null, pc.sperson) nombre,
       nvl(pac_isqlfor.f_telefono(pc.sperson),' ') telefono
      FROM ctgar_contragarantia ctc, per_contragarantia pc, ctgar_seguro s
        WHERE pc.scontgar = ctc.scontgar
        AND ctc.scontgar = s.scontgar
        AND s.sseguro =  p_sseguro;

    vicapital NUMBER := 0;
    vreturn VARCHAR2(2000);
  BEGIN

   IF p_tipo = 1 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.nradica || '<br>';
      END LOOP;
   ELSIF p_tipo = 2 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.ctipo || '<br>';
      END LOOP;
   ELSIF p_tipo = 3 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.corigen || '<br>';
      END LOOP;
   ELSIF p_tipo = 4 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.cestado || '<br>';
      END LOOP;
   ELSIF p_tipo = 5 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.nif || '<br>';
      END LOOP;
   ELSIF p_tipo = 6 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.nombre || '<br>';
      END LOOP;
   ELSIF p_tipo = 7 THEN
      FOR var IN c_ctgar LOOP
               vreturn := vreturn || var.telefono || '<br>';
      END LOOP;
   END IF;

    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_get_contratragarantias;



     /*************************************************************************
      FUNCTION f_get_coaseguro
      FunciÃ¯Â¿Â½n que se utilizarÃ¯Â¿Â½ para obtener los datos de las garantÃ¯Â¿Â½as contratadas en un convenio,su capital asegurado, carencia, franquicia, limite prestaciÃ¯Â¿Â½n y RevalorizaciÃ¯Â¿Â½n.
      param in P_SSEGURO    : NÃ¯Â¿Â½mero de seguro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 Ã¯Â¿Â½ 1er Columna desc. de garantÃ¯Â¿Â½as,  textos 2- 2Ã¯Â¿Â½ columna,Capitales asegurados, primas,etc
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_get_coaseguro(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2 IS
     vreturn VARCHAR2(2000);

  BEGIN

    vreturn:= nvl(pac_isqlfor.f_get_coacuadro(p_sseguro,p_tipo),' ');
    IF vreturn = ' ' THEN 
      vreturn:= nvl(pac_isqlfor.f_get_coacedido(p_sseguro,p_tipo),' ');  
   END IF;



    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_get_coaseguro;

   /*************************************************************************
      FUNCTION f_get_tramitejudicial
      FunciÃ¯Â¿Â½n que se utilizarÃ¯Â¿Â½ para obtener los datos de las garantÃ¯Â¿Â½as contratadas en un convenio,su capital asegurado, carencia, franquicia, limite prestaciÃ¯Â¿Â½n y RevalorizaciÃ¯Â¿Â½n.
      param in P_SSEGURO    : NÃ¯Â¿Â½mero de seguro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 Ã¯Â¿Â½ 1er Columna desc. de garantÃ¯Â¿Â½as,  textos 2- 2Ã¯Â¿Â½ columna,Capitales asegurados, primas,etc
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
  FUNCTION f_get_tramitejudicial(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2 IS

    CURSOR c_tramijudi IS
      SELECT  dest.ttramit, st.nradica,  stm.ctramitad||' - '||sct.ttramitad abogado, st.fmodifi, st.nsinies
        FROM sin_tramitacion st, sin_codtramitacion sc, sin_destramitacion dest, sin_tramita_movimiento stm, sin_codtramitador sct, sin_siniestro s
          WHERE  dest.cidioma = 8
          AND   sc.ctramit = st.ctramit
          AND   dest.ctramit = st.ctramit
          AND   stm.ctramitad = sct.ctramitad
          AND   stm.ntramit = st.ntramit
          AND   stm.nsinies = st.nsinies
          AND   st.nsinies  = s.nsinies
          AND   st.ntramit = (SELECT MAX(ntramit) from sin_tramitacion where nsinies= s.nsinies and ctramit =st.ctramit)
          AND   s.sseguro =   p_sseguro;

    vicapital NUMBER := 0;
    vreturn VARCHAR2(2000);
  BEGIN

   IF p_tipo = 1 THEN
      FOR var IN c_tramijudi LOOP
               vreturn := vreturn || var.ttramit || '<br>';
      END LOOP;
   ELSIF p_tipo = 2 THEN
      FOR var IN c_tramijudi LOOP
               vreturn := vreturn || var.nradica || '<br>';
      END LOOP;
   ELSIF p_tipo = 3 THEN
      FOR var IN c_tramijudi LOOP
               vreturn := vreturn || var.abogado || '<br>';
      END LOOP;
   ELSIF p_tipo = 4 THEN
      FOR var IN c_tramijudi LOOP
               vreturn := vreturn || var.fmodifi || '<br>';
      END LOOP;
   END IF;

    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_get_tramitejudicial;

   /*************************************************************************
      FUNCTION f_get_tramitecnico
      FunciÃ¯Â¿Â½n que se utilizarÃ¯Â¿Â½ para obtener los datos de las garantÃ¯Â¿Â½as contratadas en un convenio,su capital asegurado, carencia, franquicia, limite prestaciÃ¯Â¿Â½n y RevalorizaciÃ¯Â¿Â½n.
      param in p_nsinies    : NÃ¯Â¿Â½mero de sinies
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 Ã¯Â¿Â½ 1er Columna desc. de garantÃ¯Â¿Â½as,  textos 2- 2Ã¯Â¿Â½ columna,Capitales asegurados, primas,etc
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_get_tramitecnico(
      p_nsinies IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2 IS

    CURSOR c_tramirecnico IS
     SELECT SP.SINTAPOY,(SELECT ttramitad FROM SIN_CODTRAMITADOR WHERE ctramitad=SP.cunitra) cunitra,
          SC.ttramitad ctramitad ,SP.falta  FROM SIN_TRAMITA_APOYOS SP, SIN_CODTRAMITADOR SC   WHERE nsinies =p_nsinies 
          AND SC.ctramitad = SP.ctramitad
           ORDER BY SP.SINTAPOY DESC ;

    vicapital NUMBER := 0;
    vreturn VARCHAR2(2000);
  BEGIN

   IF p_tipo = 1 THEN
      FOR var IN c_tramirecnico LOOP
               vreturn := vreturn || var.SINTAPOY || '<br>';
      END LOOP;
   ELSIF p_tipo = 2 THEN
      FOR var IN c_tramirecnico LOOP
               vreturn := vreturn || var.cunitra || '<br>';
      END LOOP;
   ELSIF p_tipo = 3 THEN
      FOR var IN c_tramirecnico LOOP
               vreturn := vreturn || var.ctramitad || '<br>';
      END LOOP;
   ELSIF p_tipo = 4 THEN
      FOR var IN c_tramirecnico LOOP
               vreturn := vreturn || var.falta || '<br>';
      END LOOP;
   END IF;

    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_get_tramitecnico;


   /*************************************************************************
     FUNCTION f_get_reaseguro
      param in p_sseguro    : NÃ¯Â¿Â½mero de seguro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 Ã¯Â¿Â½ aÃ¯Â¿Â½o, 2 RETENCIÃ¯Â¿Â½N,  3 %RET,
                              4 PARTE 1,  5 %C1,
                              6 PARTE 2,  7 %C2,
                              8 PARTE 3,  9 %C3
                              10 FACULTATIVO,   11 %FA.
   *************************************************************************/
   FUNCTION f_get_reaseguro(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2 IS

    CURSOR c_reaseguro(tramo NUMBER) IS
      SELECT c.icapces, c.pcesion, to_char(co.fconini, 'yyyy') fconini
          FROM cesionesrea c, contratos co
         WHERE  co.nversio = c.nversio
           AND  co.scontra = c.scontra
           AND c.ctramo = tramo
           AND c.sseguro = p_sseguro;

    vicapital NUMBER := 0;
    vreturn VARCHAR2(2000);
  BEGIN

   IF p_tipo = 1 THEN
      FOR var IN c_reaseguro(0) LOOP
               vreturn := vreturn || var.fconini || '<br>';
      END LOOP;
   ELSIF p_tipo = 2 THEN
      FOR var IN c_reaseguro(0) LOOP
               vreturn := vreturn || var.icapces || '<br>';
      END LOOP;
   ELSIF p_tipo = 3 THEN
      FOR var IN c_reaseguro(0) LOOP
               vreturn := vreturn || var.pcesion ||' %'|| '<br>';
      END LOOP;
   ELSIF p_tipo = 4 THEN
      FOR var IN c_reaseguro(1) LOOP
               vreturn := vreturn || var.icapces || '<br>';
      END LOOP;
   ELSIF p_tipo = 5 THEN
      FOR var IN c_reaseguro(1) LOOP
               vreturn := vreturn || var.pcesion ||' %'|| '<br>';
      END LOOP;
   ELSIF p_tipo = 6 THEN
      FOR var IN c_reaseguro(2) LOOP
               vreturn := vreturn || var.icapces || '<br>';
      END LOOP;
   ELSIF p_tipo = 7 THEN
      FOR var IN c_reaseguro(2) LOOP
               vreturn := vreturn || var.pcesion ||' %'|| '<br>';
      END LOOP;
   ELSIF p_tipo = 8 THEN
      FOR var IN c_reaseguro(3) LOOP
               vreturn := vreturn || var.icapces || '<br>';
      END LOOP;
   ELSIF p_tipo = 9 THEN
      FOR var IN c_reaseguro(3) LOOP
               vreturn := vreturn || var.pcesion ||' %'|| '<br>';
      END LOOP;
   ELSIF p_tipo = 10 THEN
      FOR var IN c_reaseguro(5) LOOP
               vreturn := vreturn || var.icapces || '<br>';
      END LOOP;
   ELSIF p_tipo = 11 THEN
      FOR var IN c_reaseguro(5) LOOP
               vreturn := vreturn || var.pcesion ||' %'|| '<br>';
      END LOOP;
   END IF;

    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_get_reaseguro;

   /*************************************************************************
      FUNCTION f_get_conpagopersona
      FunciÃ³n que se utilizarÃ¡ para obtener los datos de las garantÃ­as contratadas en un convenio,su capital asegurado, carencia, franquicia, limite prestaciÃ³n y RevalorizaciÃ³n.
      param in p_sperson    : codigo persona
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    :
      param in p_fdesde : fecha rango inicio
      param in p_fhasta : fecha rango fin
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_get_conpagopersona(
      p_sperson IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER,
      p_fdesde IN   DATE,
      p_fhasta IN   DATE
      )
      RETURN VARCHAR2 IS

    CURSOR c_ccopago IS
       SELECT distinct ', Sucursal:'||replace(pac_isqlfor_conf.f_get_sucursal(2,s.cagente),'<br>','')||' '||/*Substr(ff_desvalorfijo(803, p_cidioma, st.cconpag),5)*/nvl(tobserva,' ') tcconpag, st.nsinies, s.npoliza,st.nfacref FROM sin_tramita_pago st, seguros s
          WHERE s.sseguro = (select sseguro from sin_siniestro where nsinies =  st.nsinies)
          AND st.sperson = p_sperson and 
          fordpag BETWEEN p_fdesde and p_fhasta;

    CURSOR c_importes IS
      SELECT  sum(st.ISINRET) ISINRET, sum(st.IIVA) IIVA, -sum(st.IRETEIVA) IRETEIVA, -sum(st.IRETENC) IRETENC, -sum(st.IRETEICA) IRETEICA, sum(case when st.IOTROSGAS is null THEN 0 ELSE st.IOTROSGAS END) IOTROSGAS
       FROM sin_tramita_pago st , seguros s
          WHERE s.sseguro = (select sseguro from sin_siniestro where nsinies =  st.nsinies)
          AND  st.sperson = p_sperson  and 
          fordpag BETWEEN p_fdesde and p_fhasta;
    vicapital NUMBER := 0;
    vreturn VARCHAR2(2000);
    vtotal NUMBER := 0;
  BEGIN

IF p_tipo = 1 THEN
      FOR var IN c_ccopago LOOP
               vreturn := vreturn ||'Stro.: '|| var.nsinies ||' , poliza N: '|| var.npoliza||'  '|| var.tcconpag||' , N fact: '|| var.nfacref|| '<br>';
      END LOOP;
  ELSIF p_tipo = 2 THEN
        vreturn := vreturn ||'VALOR OPERACION'|| '<br>';
        vreturn := vreturn ||'VALOR IVA DESCONTABLE(+)'|| '<br>';
        vreturn := vreturn ||'VALOR IVA RETENIDO(-)'|| '<br>';
        vreturn := vreturn ||'VALOR RETEFUENTE(-)'|| '<br>';
        vreturn := vreturn ||'VALOR RETE ICA (-) '|| '<br>';
        vreturn := vreturn ||'GASTOS (+) '|| '<br>';
        vreturn := vreturn ||' '|| '<br>';
        vreturn := vreturn ||'NETO A PAGAR'|| '<br>';
  ELSIF p_tipo = 3 THEN
      FOR var IN c_importes LOOP
      vtotal := vtotal + var.ISINRET + var.IIVA + var.IRETEIVA + var.IRETENC + var.IRETEICA + var.IOTROSGAS;
        vreturn := vreturn ||TO_CHAR(var.ISINRET, 'FM999G999G999G999G990D90')|| '<br>';
        vreturn := vreturn ||TO_CHAR(var.IIVA, 'FM999G999G999G999G990D90')|| '<br>';
        vreturn := vreturn ||TO_CHAR(var.IRETEIVA, 'FM999G999G999G999G990D90')|| '<br>';
        vreturn := vreturn ||TO_CHAR(var.IRETENC, 'FM999G999G999G999G990D90')|| '<br>';
        vreturn := vreturn ||TO_CHAR(var.IRETEICA, 'FM999G999G999G999G990D90')|| '<br>';
        vreturn := vreturn ||TO_CHAR(var.IOTROSGAS, 'FM999G999G999G999G990D90')|| '<br>';
        vreturn := vreturn ||lpad('=',20,'=')|| '<br>';
        vreturn := vreturn ||TO_CHAR(vtotal, 'FM999G999G999G999G990D90')|| '<br>';
      END LOOP;
  END IF;

    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_get_conpagopersona;

   /*************************************************************************
      FUNCTION f_get_conpagopersona
      param in p_sperson      : codigo persoa
      p_parametro IN VARCHAR2 :nombre parametro
      param in CIDIOMA        : Identificador de idioma.
      param in p_sfinanci     : sfinanci
      return                  : Tablas de donde se obtienen los datos, por defecto POL.
      (p_tipo 3               : Retorna valor sin formato)
   *************************************************************************/
     -- Inicio IAXIS-2122 -- ECP -- 29/04/20|9
   FUNCTION f_get_ficha (
      p_parametro   IN   VARCHAR2,
      p_cidioma     IN   NUMBER,
      p_sfinanci    IN   NUMBER,
      p_nmovimi     IN   NUMBER,
      p_tipo        IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      CURSOR c_fichero
      IS
--INICIO IAXIS-3647 Plantilla USF  - I.R.D

             -- Ini IAXIS-7788 -- 28/04/2020
             SELECT TO_CHAR (fvalpar, 'yyyy') fvalpar,
                    TO_CHAR (fvalpar, 'dd/mm/yyyy') fvalpar_01, --IAXIS-2122 --JLTS -10/02/2020
                    nvl(replace(replace((tvalpar), ',', ''), '.', ''), replace(replace((nvalpar), ',', ''), '.', '')) valpar
                    FROM fin_parametros a, fin_indicadores b
          WHERE a.sfinanci = p_sfinanci and a.cparam = p_parametro and a.nmovimi = b.nmovimi and b.nmovimi = p_nmovimi  AND  a.sfinanci = b.sfinanci 
           and a.nmovimi = (select max(c.nmovimi) from fin_parametros c where c.sfinanci = a.sfinanci and c.cparam = a.cparam and c.nmovimi <= b.nmovimi);
-- Ini IAXIS-7788 -- 28/04/2020   

--FIN IAXIS-3647 Plantilla USF  - I.R.D
      vvalor    NUMBER       := 0;
      vfvalor   VARCHAR2 (4);
       -- INI -IAXIS-2122 --JLTS -10/02/2020
      vfvalor_f1   VARCHAR2 (10);
       -- FIN -IAXIS-2122 --JLTS -10/02/2020
   BEGIN
      OPEN c_fichero;

      FETCH c_fichero
       INTO vfvalor, 
            vfvalor_f1,   -- IAXIS-2122 --JLTS -10/02/2020
            vvalor;

      CLOSE c_fichero;

      IF p_tipo = 1
      THEN
         RETURN vfvalor;
      -- INI IAXIS-3750 - RABQ 
      ELSIF P_TIPO = 3 THEN 
        RETURN nvl(vvalor,0);
      -- FIN IAXIS-3750 - RABQ
      ELSE
        --INI -IAXIS-2122 --JLTS -10/02/2020
        IF p_tipo = 12 then -- Formato fecha en formato DD/MM/YYYY
          RETURN vfvalor_f1;
        ELSE
	--FIN -IAXIS-2122 --JLTS -10/02/2020
         RETURN NVL (TO_CHAR (vvalor, 'FM999G999G999G999G990D90'), 0);
        END IF; --IAXIS-2122 --JLTS -10/02/2020
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_get_ficha;
-- Fin IAXIS-2122 -- ECP -- 29/04/20|9
 /*************************************************************************
      FUNCTION f_get_conpagopersona
      param in p_sperson    : codigo persoa
      p_parametro IN VARCHAR2 :nombre parametro
      param in CIDIOMA     : Identificador de idioma.
      param in p_sfinanci    : sfinanci
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
  FUNCTION f_get_ficha(
      p_parametro IN VARCHAR2,
      p_cidioma IN NUMBER,
      p_sfinanci IN NUMBER,
      p_tipo   IN NUMBER)
      RETURN VARCHAR2 IS

    CURSOR c_fichero IS
      SELECT  to_char(FVALPAR, 'yyyy') FVALPAR, nvl(to_char(NVALPAR), to_char(TVALPAR)) VALPAR FROM  FIN_PARAMETROS --axis-3152
        WHERE  CPARAM = p_parametro
        and nmovimi = p_sfinanci;  --iaxis-3152

      vvalor varchar2(2000) ;
      vfvalor VARCHAR2(4);
  BEGIN

    OPEN c_fichero;
    FETCH c_fichero INTO vfvalor, vvalor;
    CLOSE c_fichero;

    IF p_tipo = 1 THEN
        RETURN vfvalor;
    ELSE
    RETURN nvl(TO_CHAR(REPLACE(vvalor,',',''), 'FM999G999G999G999G990D90'), 0);  ---axis-3152
    END IF;


  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_get_ficha;

    --Inicio IAXIS-2122 -- ECP -- 11/04/2019
    /*************************************************************************
      FUNCTION f_get_sfinanci
      param in p_sperson    : codigo persoa

   *************************************************************************/
   FUNCTION f_get_sfinanci (p_sperson IN NUMBER, p_tipo IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR c_sfinanci
      IS
      -- IAXIS-5154 - JLTS - 09/09/2019 - Se ajusta sfinaci por nmovimi
         SELECT   rownum, b.nmovimi --iaxis-3152
             FROM fin_general a, fin_indicadores b
            WHERE a.sperson = p_sperson
              AND a.sfinanci = b.sfinanci
              AND TO_NUMBER (TO_CHAR (b.findicad, 'yyyy')) >=
                                    TO_NUMBER (TO_CHAR (f_sysdate, 'yyyy'))
                                    - 3

         ORDER BY b.findicad desc;

      vvalor      NUMBER := 0;
      vcontador   NUMBER := 1;
   BEGIN

      FOR var IN c_sfinanci LOOP
      -- IAXIS-5154 - JLTS - 09/09/2019 - Se ajusta sfinaci por nmovimi
        vvalor := var.nmovimi;--iaxis-3152



        IF  p_tipo =  vcontador  THEN
            EXIT;
        END IF;

        IF  c_sfinanci%ROWCOUNT = 1 AND  p_tipo != 1 THEN
            vvalor := -1;
        elsif c_sfinanci%ROWCOUNT != p_tipo then
            vvalor := -1;
        END IF;
        vcontador := vcontador + 1;
    END LOOP;
    RETURN vvalor;

   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_get_sfinanci;
--Fin IAXIS-2122 -- ECP -- 11/04/2019

    /*************************************************************************
      FUNCTION f_get_porcenfinanci
      p_tipo   IN NUMBER,
      p_parametro1 IN VARCHAR2,
      p_sfinanci IN NUMBER,
      p_mv_sfinanci1   IN NUMBER,
      p_parametro1 IN VARCHAR2,
      p_mv_sfinanci1   IN NUMBER

   *************************************************************************/
   FUNCTION f_get_porcenfinanci(
      p_tipo   IN NUMBER,
      p_sfinanci IN NUMBER, -- IAXIS-2122 -JLTS -11/02/2020
      p_parametro1 IN VARCHAR2,
      p_mv_sfinanci1   IN NUMBER,
      p_parametro2 IN VARCHAR2,
      p_mv_sfinanci2   IN NUMBER) 
      RETURN VARCHAR2 IS
    -- INI - IAXIS-2122 -11/02/2020
    CURSOR c_valor (p_parametro VARCHAR2, p_sfinanci NUMBER, p_mv_sfinanci1 NUMBER) IS
      SELECT  NVL (nvalpar, REPLACE (tvalpar, '.', '')) FROM  FIN_PARAMETROS p
        WHERE p.CPARAM = p_parametro
        and p.SFINANCI = p_sfinanci
        and p.nmovimi  = p_mv_sfinanci1;
    -- FIN - IAXIS-2122 -11/02/2020


      vvalor1 NUMBER := 0;
      vvalor2 NUMBER := 0;
      porcentaje NUMBER := 0;
      vfvalor DATE;
  BEGIN


    OPEN c_valor (p_parametro1, p_sfinanci, p_mv_sfinanci1); -- IAXIS-2122 -11/02/2020
      FETCH c_valor INTO  vvalor1;
    CLOSE c_valor;

    OPEN c_valor (p_parametro2, p_sfinanci, p_mv_sfinanci2); -- IAXIS-2122 -11/02/2020
      FETCH c_valor INTO  vvalor2;
    CLOSE c_valor;
-- IAXIS-7791 -- 21/05/2020
  IF  p_tipo = 1 THEN
    IF vvalor1 != 0 AND vvalor2 != 0 THEN
       porcentaje := (vvalor1 * 100)/vvalor2;
    END IF;
  ELSE
      IF vvalor1 != 0 AND vvalor2 != 0 THEN
       porcentaje := ((vvalor1 - vvalor2) * 100)/vvalor2;
      elsif vvalor2 = 0 then
         porcentaje := 0;
      elsif vvalor1 = 0 then
         porcentaje := ((vvalor1 - vvalor2) * 100)/vvalor2;
    END IF;
  END IF;
  -- IAXIS-7791 -- 21/05/2020
  p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ISQLFOR_CONF.f_porcentaje',
                      1,
                      null,
           'p_mv_sfinanci1-->'||p_mv_sfinanci1||'p_sfinanci-->'||p_sfinanci||'p_mv_sfinanci2-->'||p_mv_sfinanci2||' p_parametro1-->'||p_parametro1||'p_parametro2-->'||p_parametro2||'vvalor1 -->'||vvalor1||'vvalor2-->'||vvalor2||'vvalor1 '||vvalor1||'vvalor2'||vvalor2||'porcentaje '||porcentaje||'p_tipo -->'||p_tipo);

  RETURN ROUND(porcentaje, 2);
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_get_porcenfinanci;

--INI BUG CONF 304 - Desarrollo INT06 (CÃ¯Â¿Â½DIGO BRIDGER) - DMCOTTE
--funciÃ¯Â¿Â½n que trae los roles de una persona en una cadena de caracteres para reporte bridger

  FUNCTION f_roles_persona(
    psperson IN NUMBER
  ) RETURN VARCHAR2
  IS
    vtipo NUMBER := 0;
    vroles VARCHAR2(2000);
  BEGIN

    select count(*) into vtipo
      from tomadores where sperson = psperson;

    if vtipo > 0 then
      vroles := vroles || 'Tomador';
    end if;

    select count(*)into vtipo
      from asegurados where sperson = psperson;

    if vtipo >0 then
      if vroles != ' ' then
        vroles := vroles || ' - ';
      end if;
      vroles := vroles || 'Asegurado';
    end if;

    select count(*) into vtipo
      from beneficiarios where sperson = psperson;
    if vtipo >0 then
      if vroles != ' ' then
        vroles := vroles || ' - ';
      end if;
      vroles := vroles || 'Beneficiario';
    end if;

    select count(*) into vtipo
      from agentes where sperson = psperson;
    if vtipo >0 then
      if vroles != ' ' then
        vroles := vroles || ' - ';
      end if;
      vroles := vroles || 'Agente';
    end if;

    RETURN vroles;

  END f_roles_persona;
--FIN BUG CONF 304 - Desarrollo INT06 (CÃ¯Â¿Â½DIGO BRIDGER) - DMCOTTE


   /*************************************************************************
      FUNCTION f_get_tramreserva
      param in p_nsinies    : NÃ¯Â¿Â½mero de siniestro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 Ã¯Â¿Â½ 1er Columna desc. de garantÃ¯Â¿Â½as,  textos 2- 2Ã¯Â¿Â½ columna,Capitales asegurados, primas,etc
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_get_tramreserva(
      p_nsinies IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER) 
      RETURN VARCHAR2  IS

    CURSOR c_tramireserva IS
             SELECT DISTINCT(dest.ttramit),
              st.nradica,
              gg.tgarant,
              nvl(ff_desvalorfijo(1090, 8, st.csubtiptra), ' ') tipo,
              nvl(tr.ireserva, 0) ireserva,
              tr.cmonres,
              nvl(tr.ifranq, 0) ifranq,
              nvl(vp.ipreten, 0) ipreten
         FROM sin_destramitacion dest, sin_tramita_reserva tr, garangen gg,
              sin_tramita_valpretension vp, sin_tramitacion st
        WHERE  dest.cidioma = 8
          AND gg.cidioma = 8
          AND tr.ntramit = st.ntramit
          AND tr.nsinies = st.nsinies
          AND gg.cgarant = tr.cgarant
          AND tr.nsinies = vp.nsinies(+)
          AND tr.ntramit = vp.ntramit(+)
          AND tr.cgarant = vp.cgarant(+)
          AND tr.nsinies = p_nsinies
          AND NVL(vp.norden, 0) =
              NVL((SELECT MAX(norden)
                    FROM sin_tramita_valpretension vpr
                   WHERE vpr.nsinies = vp.nsinies
                     AND vpr.ntramit = vp.ntramit), 0);

    vicapital NUMBER := 0;
    vreturn VARCHAR2(2000);
    BEGIN

       IF p_tipo = 1 THEN
          FOR var IN c_tramireserva LOOP
                   vreturn := vreturn || var.ttramit || '<br>';
          END LOOP;
       ELSIF p_tipo = 2 THEN
          FOR var IN c_tramireserva LOOP
                   vreturn := vreturn || var.nradica || '<br>';
          END LOOP;
       ELSIF p_tipo = 3 THEN
          FOR var IN c_tramireserva LOOP
                   vreturn := vreturn || var.tgarant || '<br>';
          END LOOP;
       ELSIF p_tipo = 4 THEN
          FOR var IN c_tramireserva LOOP
                   vreturn := vreturn || var.tipo || '<br>';
          END LOOP;
       ELSIF p_tipo = 5 THEN
          FOR var IN c_tramireserva LOOP
                   vreturn := vreturn || TO_CHAR(var.ireserva, 'FM999G999G999G999G990D90') || '<br>';
          END LOOP;
       ELSIF p_tipo = 6 THEN
          FOR var IN c_tramireserva LOOP
                   vreturn := vreturn || var.cmonres || '<br>';
          END LOOP;
       ELSIF p_tipo = 7 THEN
          FOR var IN c_tramireserva LOOP
                   vreturn := vreturn || TO_CHAR(var.ifranq, 'FM999G999G999G999G990D90') || '<br>';
          END LOOP;
       ELSIF p_tipo = 8 THEN
          FOR var IN c_tramireserva LOOP
                   vreturn := vreturn || TO_CHAR(var.ipreten, 'FM999G999G999G999G990D90') || '<br>';
          END LOOP;
       END IF;

        RETURN vreturn;
    EXCEPTION
        WHEN OTHERS THEN

                   RETURN NULL;
    END f_get_tramreserva;

    FUNCTION f_direccion(
      p_sperson IN  NUMBER,
      p_cdomici IN  NUMBER,
      p_mode  IN  VARCHAR2 DEFAULT 'POL'
  ) RETURN VARCHAR2
  IS
    pcsiglas     per_direcciones.csiglas%TYPE;
    ptnomvia     per_direcciones.tnomvia%TYPE;
    pnnumvia     per_direcciones.nnumvia%TYPE;
    ptcomple     per_direcciones.tcomple%TYPE;
    pcviavp      per_direcciones.cviavp%TYPE;
    pclitvp      per_direcciones.clitvp%TYPE;
    pcbisvp      per_direcciones.cbisvp%TYPE;
    pcorvp       per_direcciones.corvp%TYPE;
    pnviaadco    per_direcciones.nviaadco%TYPE;
    pclitco      per_direcciones.clitco%TYPE;
    pcorco       per_direcciones.corco%TYPE;
    pnplacaco    per_direcciones.nplacaco%TYPE;
    pcor2co      per_direcciones.cor2co%TYPE;
    pcdet1ia     per_direcciones.cdet1ia%TYPE;
    ptnum1ia     per_direcciones.tnum1ia%TYPE;
    pcdet2ia     per_direcciones.cdet2ia%TYPE;
    ptnum2ia     per_direcciones.tnum2ia%TYPE;
    pcdet3ia     per_direcciones.cdet3ia%TYPE;
    ptnum3ia     per_direcciones.tnum3ia%TYPE;
    vtsiglas     VARCHAR2(2):=NULL;
    vtdescsiglas VARCHAR2(32000):=NULL;
    vnnomvia     NUMBER;
    vnnumvia     NUMBER;
    vncomple     NUMBER;
    vtdomici     per_direcciones.tdomici%TYPE;
    tviavp       VARCHAR2(250);
    tdet1ia      VARCHAR2(50);
    tdet2ia      VARCHAR2(50);
    tdet3ia      VARCHAR2(50);
    tclitvp      VARCHAR2(50);
    tbisvp       VARCHAR2(50);
    tcorvp       VARCHAR2(50);
    tlitco       VARCHAR2(50);
    tcorco       VARCHAR2(50);
    tor2co       VARCHAR2(50);
  BEGIN
      IF p_mode='POL' THEN
        SELECT csiglas,tnomvia,nnumvia,tcomple,cviavp,clitvp,cbisvp,corvp,nviaadco,clitco,corco,nplacaco,cor2co,cdet1ia,tnum1ia,cdet2ia,tnum2ia,cdet3ia,tnum3ia
          INTO pcsiglas, ptnomvia, pnnumvia, ptcomple,
        pcviavp, pclitvp, pcbisvp, pcorvp,
        pnviaadco, pclitco, pcorco, pnplacaco,
        pcor2co, pcdet1ia, ptnum1ia, pcdet2ia,
        ptnum2ia, pcdet3ia, ptnum3ia
          FROM per_direcciones
         WHERE sperson=p_sperson AND
               cdomici=p_cdomici;
      ELSE
        SELECT csiglas,tnomvia,nnumvia,tcomple,cviavp,clitvp,cbisvp,corvp,nviaadco,clitco,corco,nplacaco,cor2co,cdet1ia,tnum1ia,cdet2ia,tnum2ia,cdet3ia,tnum3ia
          INTO pcsiglas, ptnomvia, pnnumvia, ptcomple,
        pcviavp, pclitvp, pcbisvp, pcorvp,
        pnviaadco, pclitco, pcorco, pnplacaco,
        pcor2co, pcdet1ia, ptnum1ia, pcdet2ia,
        ptnum2ia, pcdet3ia, ptnum3ia
          FROM estper_direcciones
         WHERE sperson=p_sperson AND
               cdomici=p_cdomici;
      END IF;

      IF pcsiglas IS NOT NULL THEN BEGIN
            SELECT tsiglas
              INTO vtsiglas
              FROM tipos_via
             WHERE csiglas=pcsiglas;

            vtdomici:=vtsiglas
                      || ' ';
        EXCEPTION
            WHEN OTHERS THEN
              vtsiglas:=NULL;
        END;
      END IF;

      IF pcviavp IS NOT NULL THEN BEGIN
            /* SELECT tatribu
               INTO vtdescsiglas
               FROM detvalores
              WHERE cidioma = 8
                AND cvalor = 800042
                AND catribu = pcviavp;*/
            SELECT tdenom
              INTO vtdescsiglas
              FROM destipos_via
             WHERE cidioma=8 AND
                   csiglas=pcviavp;

            vtdomici:=vtdescsiglas
                      || ' ';
        EXCEPTION
            WHEN OTHERS THEN
              vtdescsiglas:=NULL;
        END;
      END IF;

      vnnomvia:=nvl(length(ptnomvia), 0);

      vnnumvia:=nvl(length(pnnumvia), 0);

      vncomple:=nvl(length(ptcomple), 0);

      IF (vnnomvia+vnnumvia+vncomple+8)<100 THEN
        SELECT vtdomici
               || ptnomvia
               || decode(pnnumvia, NULL, NULL,
                                   ' ')
               || pnnumvia
               || f_axis_literales(9001323, f_usu_idioma)
               || decode(ptcomple, NULL, NULL,
                                   ' ')
               || ptcomple
          INTO vtdomici
          FROM dual;
      ELSE
        SELECT vtdomici
               || substr(ptnomvia, 0, 100-(vnnumvia+vncomple+8))
               || decode(pnnumvia, NULL, NULL,
                                   ' ')
               || pnnumvia
               || f_axis_literales(9001323, f_usu_idioma)
               || decode(ptcomple, NULL, NULL,
                                   ' ')
               || ptcomple
          INTO vtdomici
          FROM dual;
      END IF;

      IF pclitvp IS NOT NULL THEN BEGIN
            SELECT tatribu
              INTO tclitvp
              FROM detvalores
             WHERE cidioma=f_usu_idioma AND
                   cvalor=800043 AND
                   catribu=pclitvp;

            IF vtdomici IS NULL THEN
              vtdomici:=tclitvp;
            ELSE
              vtdomici:=vtdomici
                        || ' '
                        || tclitvp;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
              NULL;
        END;
      END IF;

      IF pcbisvp IS NOT NULL THEN BEGIN
            SELECT tatribu
              INTO tbisvp
              FROM detvalores
             WHERE cidioma=f_usu_idioma AND
                   cvalor=800044 AND
                   catribu=pcbisvp;

            IF vtdomici IS NULL THEN
              vtdomici:=tbisvp;
            ELSE
              vtdomici:=vtdomici
                        || ' '
                        || tbisvp;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
              NULL;
        END;
      END IF;

      IF pcorvp IS NOT NULL THEN BEGIN
            SELECT tatribu
              INTO tcorvp
              FROM detvalores
             WHERE cidioma=f_usu_idioma AND
                   cvalor=800045 AND
                   catribu=pcorvp;

            IF vtdomici IS NULL THEN
              vtdomici:=tcorvp;
            ELSE
              vtdomici:=vtdomici
                        || ' '
                        || tcorvp;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
              NULL;
        END;
      END IF;

      IF pnviaadco IS NOT NULL THEN
        vtdomici:=vtdomici
                  || ' '
                  || pnviaadco;
      END IF;

      IF pclitco IS NOT NULL THEN BEGIN
            SELECT tatribu
              INTO tlitco
              FROM detvalores
             WHERE cidioma=f_usu_idioma AND
                   cvalor=800043 AND
                   catribu=pclitco;

            IF vtdomici IS NULL THEN
              vtdomici:=tlitco;
            ELSE
              vtdomici:=vtdomici
                        || ' '
                        || tlitco;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
              NULL;
        END;
      END IF;

      IF pcorco IS NOT NULL THEN BEGIN
            SELECT tatribu
              INTO tcorco
              FROM detvalores
             WHERE cidioma=f_usu_idioma AND
                   cvalor=800045 AND
                   catribu=pcorco;

            IF vtdomici IS NULL THEN
              vtdomici:=tcorco;
            ELSE
              vtdomici:=vtdomici
                        || ' '
                        || tcorco;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
              NULL;
        END;
      END IF;

      IF pnplacaco IS NOT NULL THEN
        vtdomici:=vtdomici
                  || ' '
                  || pnplacaco;
      END IF;

      IF pcor2co IS NOT NULL THEN BEGIN
            SELECT tatribu
              INTO tor2co
              FROM detvalores
             WHERE cidioma=f_usu_idioma AND
                   cvalor=800045 AND
                   catribu=pcor2co;

            IF vtdomici IS NULL THEN
              vtdomici:=tor2co;
            ELSE
              vtdomici:=vtdomici
                        || ' '
                        || tor2co;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
              NULL;
        END;
      END IF;

      IF pcdet1ia IS NOT NULL THEN BEGIN
            SELECT tatribu
              INTO tdet1ia
              FROM detvalores
             WHERE cidioma=f_usu_idioma AND
                   cvalor=800047 AND
                   catribu=pcdet1ia;

            IF vtdomici IS NULL THEN
              vtdomici:=tdet1ia;
            ELSE
              vtdomici:=vtdomici
                        || ' '
                        || tdet1ia;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
              NULL;
        END;
      END IF;

      IF ptnum1ia IS NOT NULL THEN
        IF vtdomici IS NULL THEN
          vtdomici:=ptnum1ia;
        ELSE
          vtdomici:=vtdomici
                    || ' '
                    || ptnum1ia;
        END IF;
      END IF;

      IF pcdet2ia IS NOT NULL THEN BEGIN
            SELECT tatribu
              INTO tdet2ia
              FROM detvalores
             WHERE cidioma=f_usu_idioma AND
                   cvalor=800047 AND
                   catribu=pcdet2ia;

            IF vtdomici IS NULL THEN
              vtdomici:=tdet2ia;
            ELSE
              vtdomici:=vtdomici
                        || ' '
                        || tdet2ia;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
              NULL;
        END;
      END IF;

      IF ptnum2ia IS NOT NULL THEN
        IF vtdomici IS NULL THEN
          vtdomici:=ptnum2ia;
        ELSE
          vtdomici:=vtdomici
                    || ' '
                    || ptnum2ia;
        END IF;
      END IF;

      IF pcdet3ia IS NOT NULL THEN BEGIN
            SELECT tatribu
              INTO tdet3ia
              FROM detvalores
             WHERE cidioma=f_usu_idioma AND
                   cvalor=800047 AND
                   catribu=pcdet3ia;

            IF vtdomici IS NULL THEN
              vtdomici:=tdet3ia;
            ELSE
              vtdomici:=vtdomici
                        || ' '
                        || tdet3ia;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
              NULL;
        END;
      END IF;

      IF ptnum3ia IS NOT NULL THEN
        IF vtdomici IS NULL THEN
          vtdomici:=ptnum3ia;
        ELSE
          vtdomici:=vtdomici
                    || ' '
                    || ptnum3ia;
        END IF;
      END IF;

      RETURN upper(f_jrep_trad(vtdomici));
  EXCEPTION
    WHEN OTHERS THEN
               RETURN NULL;
  END f_direccion;

FUNCTION f_intermediarios(
      psseguro  IN  NUMBER,
      pnmovimi  IN  NUMBER,
      pcolumn IN  NUMBER,
      pmodo IN  VARCHAR2 DEFAULT 'POL'
  ) RETURN VARCHAR2
  IS
    vret     VARCHAR2(2000);
    vcagente NUMBER;
  BEGIN
      vret:=NULL;

      IF nvl(pmodo, 'POL')='EST' THEN
        FOR i IN (SELECT cagente,pac_isqlfor.f_agente(cagente) tagente,pac_isqlfor.f_telefono(cagente) telf,ppartici
                                                                                                            || '%' porc_part
                    FROM estage_corretaje
                   WHERE sseguro=psseguro AND
                         nmovimi=(SELECT max(nmovimi)
                                    FROM estage_corretaje
                                   WHERE sseguro=psseguro AND
                                         nmovimi<=pnmovimi)
                   ORDER BY islider DESC,cagente) LOOP
            IF pcolumn=1 THEN
              vret:=vret
                    || i.cagente
                    || ' \par ';
            ELSIF pcolumn=2 THEN
              vret:=vret
                    || i.tagente
                    || ' \par ';
            ELSIF pcolumn=3 THEN
              vret:=vret
                    || i.telf
                    || ' \par ';
            ELSIF pcolumn=4 THEN
              vret:=vret
                    || i.porc_part
                    || ' \par ';
            END IF;
        END LOOP;

        IF vret IS NULL THEN
          SELECT cagente
            INTO vcagente
            FROM estseguros
           WHERE sseguro=psseguro;

          IF pcolumn=1 THEN
            vret:=vcagente;
          ELSIF pcolumn=2 THEN
            vret:=pac_isqlfor.f_agente(vcagente);
          ELSIF pcolumn=3 THEN
            vret:=pac_isqlfor.f_telefono(vcagente);
          ELSIF pcolumn=4 THEN
            vret:='100%';
          END IF;
        END IF;
      ELSE
        FOR i IN (SELECT cagente,pac_isqlfor.f_agente(cagente) tagente,pac_isqlfor.f_telefono(cagente) telf,ppartici
                                                                                                            || '%' porc_part
                    FROM age_corretaje
                   WHERE sseguro=psseguro AND
                         nmovimi=(SELECT max(nmovimi)
                                    FROM age_corretaje
                                   WHERE sseguro=psseguro AND
                                         nmovimi<=pnmovimi)
                   ORDER BY islider DESC,cagente) LOOP
            IF pcolumn=1 THEN
              vret:=vret
                    || i.cagente
                    || ' \par ';
            ELSIF pcolumn=2 THEN
              vret:=vret
                    || i.tagente
                    || ' \par ';
            ELSIF pcolumn=3 THEN
              vret:=vret
                    || i.telf
                    || ' \par ';
            ELSIF pcolumn=4 THEN
              vret:=vret
                    || i.porc_part
                    || ' \par ';
            END IF;
        END LOOP;

        IF vret IS NULL THEN
          SELECT cagente
            INTO vcagente
            FROM seguros
           WHERE sseguro=psseguro;

          IF pcolumn=1 THEN
            vret:=vcagente;
          ELSIF pcolumn=2 THEN
            vret:=pac_isqlfor.f_agente(vcagente);

            IF (vret IS NULL) AND
               (vcagente IS NOT NULL) THEN
              SELECT pac_isqlfor.f_persona(psseguro, 1, sperson)
                INTO vret
                FROM agentes
               WHERE cagente=vcagente;
            END IF;
          ELSIF pcolumn=3 THEN
            vret:=pac_isqlfor.f_telefono(vcagente);
          ELSIF pcolumn=4 THEN
            vret:='100%';
          END IF;
        END IF;
      END IF;

      RETURN f_jrep_trad(vret);
  EXCEPTION
    WHEN OTHERS THEN
               RETURN '';
  END f_intermediarios;
  /*****************************************************************
     FUNCTION f_jrep_trad
       Formatea un varchar para su visualizaciÃ¯Â¿Â½n correcta en CSV

      param IN pentrada  : texto de entrada
      return             : texto formateado para csv
     ******************************************************************/
  FUNCTION f_jrep_trad(
      pentrada  IN  VARCHAR2
  ) RETURN VARCHAR2
  IS
  BEGIN
      IF pentrada IS NULL THEN
        RETURN NULL; /* para que funcionen los NVLS*/
      END IF;

      RETURN replace(replace('"'
                             || replace(pentrada, chr(34), chr(39))
                             || '"', '\par "', '"'), '\par ', chr(10));
  END f_jrep_trad;

   /*****************************************************************
   FUNCTION f_campaÃ¯Â¿Â½as
     funcion que trae datossobre las campaÃ¯Â¿Â½as:

    param IN p_tipo  : NUMBER de entrada
                    1: Nombre CampaÃ¯Â¿Â½a
                    2: Promedio
                    3: Recaudo
                    4: Siniestralidad
                    5: Meta
    param IN p_agente  : codigo agente
    param IN p_fini  : fecha ini
    param IN p_ffin  : fecha fin
    return             : texto formateado para csv
 ******************************************************************/
  FUNCTION f_campanas(
      p_tipo      IN   NUMBER,
      p_agente    IN   NUMBER,
      p_fini      IN   DATE,
      p_ffin      IN   DATE
  )   RETURN VARCHAR2 IS
    -- Inicio IAXIS-7813 31/01/2020
    CURSOR c_campanas(p_cagente NUMBER) IS
      SELECT DISTINCT cag.ccodigo, c.tdescrip campana, seg.cagente, c.finicam, c.ffincam, cag.imeta,
            -- Inicio IAXIS-2018 05/03/2019
            -- Se reemplaza el cÃ¯Â¿Â½lculo realizado en el cursor para obtener los valores de ProducciÃ¯Â¿Â½n
            -- y Recaudo por los campos iproduccion e irecaudo de la tabla campaage. Tener en cuenta
            -- que de ahora en adelante estos valores vienen precalculados y precargados por carga
            -- de fichero masivo.
            (/*SELECT SUM(v.itotalr)
                         FROM seguros s, recibos r, vdetrecibos_monpol v
                        WHERE s.sseguro = r.sseguro
                          AND r.nrecibo = v.nrecibo
                          AND f_cestrec(r.nrecibo,to_date('31/12/2016','dd/mm/ yy')) <> 2
                          AND s.sproduc = seg.sproduc
                          AND s.cagente = seg.cagente
                          AND NOT EXISTS (SELECT * FROM cesionesrea WHERE ctramo = 5 AND sseguro = s.sseguro)
                          AND s.cempres = NVL(24, pac_md_common.f_get_cxtempresa())
                          AND s.fefecto < = C.FFINCAM
                          AND s.fefecto > = C.FINICAM
                          AND (s.fanulac IS NULL OR s.fanulac > (SYSDATE - 31))
                        GROUP BY s.sproduc, s.cagente*/cag.iproduccion) total_prod,
            (/*SELECT SUM(v.itotalr)
                               FROM seguros s, recibos r, vdetrecibos_monpol v
                              WHERE s.sseguro = r.sseguro
                                AND r.nrecibo = v.nrecibo
                                AND s.cempres = NVL(24, pac_md_common.f_get_cxtempresa())
                                AND s.sproduc = seg.sproduc
                                AND s.cagente = seg.cagente
                                AND NOT EXISTS (SELECT * FROM cesionesrea WHERE ctramo = 5 AND sseguro = s.sseguro)
                                AND s.fefecto < = C.FFINREC
                                AND s.fefecto > = C.FINIREC
                                AND (s.fanulac IS NULL OR s.fanulac > (SYSDATE - 31))
                              GROUP BY s.sproduc, s.cagente*/cag.irecaudo) total_recaudo
          -- Fin IAXIS-2018 05/03/2019                    
         --  pac_campanas.f_get_porc_agente_sinies(P_CAGENTE) isinies
       FROM campanas c, campaage cag, seguros seg
       WHERE c.ccodigo = cag.ccodigo
         AND cag.cagente = seg.cagente
         AND cag.cagente = p_cagente --p_agente
         AND C.FFINCAM BETWEEN p_fini AND p_ffin;


    vreturn VARCHAR2(2000);

  BEGIN

  FOR var IN  c_campanas(p_agente) LOOP
      IF p_tipo = 1 THEN
          vreturn := vreturn ||var.campana|| '<br>';
      ELSIF p_tipo = 2 THEN
          vreturn := vreturn ||nvl(TO_CHAR(var.total_prod, 'FM999G999G999G999G990'), 0)|| '<br>';
      ELSIF p_tipo = 3 THEN
          vreturn := vreturn ||nvl(TO_CHAR(var.total_recaudo, 'FM999G999G999G999G990'), 0)|| '<br>';
      ELSIF p_tipo = 4 THEN
          vreturn := round(nvl(pac_campanas.f_get_porc_agente_sinies(p_agente), 0),3);  
      ELSIF p_tipo = 5 THEN
          vreturn := vreturn ||nvl(TO_CHAR(var.imeta, 'FM999G999G999G999G990'), 0)|| '<br>';
      END IF;
  END LOOP;

  RETURN vreturn;



  EXCEPTION
    WHEN OTHERS THEN
               RETURN NULL;
  END f_campanas;
  
  -- Fin IAXIS-7813 31/01/2020
  /*****************************************************************
     FUNCTION f_cumulo_persona
       Trae el cumulo de riesgo de la persona consultada

      param IN p_sperson  : SPERSON de la persona
      return             : VCUMULO
      
      
     ******************************************************************/
  FUNCTION f_cumulo_persona( p_sperson  IN  NUMBER)
    RETURN NUMBER
  IS
  mensajes        t_iax_mensajes;
  vcumulo         NUMBER;
  cur_cumulo      sys_refcursor;
  vcontador       NUMBER;
  desc_cur        DBMS_SQL.DESC_TAB;
  v_cursor        INTEGER;
  vtemp_var       VARCHAR2(4000);
   v_nnumide      per_personas.nnumide%TYPE;
  BEGIN
  -- Ini IAXIS-4785 -- ECP -- 12/12/2019
    v_nnumide := pac_isqlfor.f_dni(NULL, NULL, p_sperson);

  vcumulo := nvl(pac_cumulos_conf.f_cum_total_tom(p_nnumide => v_nnumide, p_fcorte => f_sysdate ),0);
    -- Fin IAXIS-4785 -- ECP -- 12/12/2019
    RETURN vcumulo;
  END f_cumulo_persona;
  
  /*****************************************************************
     FUNCTION f_cumulo_dep_persona
       Trae el cumulo depurado de la persona consultada

      param IN p_sperson  : SPERSON de la persona
      return             : VCUMULO
     ******************************************************************/
  FUNCTION f_cumulo_dep_persona( p_sperson  IN  NUMBER)
    RETURN NUMBER
  IS
  mensajes        t_iax_mensajes;
  vcumulo         NUMBER;
  cur_cumulo      sys_refcursor;
  vcontador       NUMBER;
  desc_cur        DBMS_SQL.DESC_TAB;
  v_cursor        INTEGER;
  vtemp_var       VARCHAR2(4000);
  BEGIN
    vcumulo:= NVL
                               (pac_cumulos_conf.f_calcula_depura_auto
                                                                     (f_sysdate,
                                                                      null,
                                                                      null,
                                                                      p_sperson
                                                                     ),
                                0
                               );

    RETURN vcumulo;
  END f_cumulo_dep_persona;

FUNCTION f_per_nombre_rel(p_sperson IN NUMBER) RETURN VARCHAR2 IS

  nombre VARCHAR2(200) := NULL;

BEGIN
  --
  IF p_sperson IS NOT NULL THEN
    --
    SELECT tapelli1 || DECODE(tapelli1, NULL, NULL, ' ') || tapelli2 ||
           DECODE(tapelli1 || tapelli2,
                  NULL,
                  NULL,
                  DECODE(tnombre, NULL, NULL, ', ')) || tnombre
      INTO nombre
      FROM PER_DETPER
     WHERE sperson = p_sperson;
    --
  ELSE
    nombre := '';
  END IF;
  --
  RETURN nombre;
END f_per_nombre_rel;

FUNCTION f_detallecoaseguro(
      ptipo IN NUMBER,
      pccompani IN NUMBER,
      psproces IN NUMBER,
      parama IN NUMBER,
      paramb IN NUMBER,
      paramc IN NUMBER)
      RETURN VARCHAR2 IS
      CURSOR c_ctates IS
         SELECT   ff_desvalorfijo(800109, 8, c.ctipcoa) ttipcoa,
                  SUM(DECODE(c.cestado, 4, 0, DECODE(cdebhab, 1, imovimi, -imovimi))) isaldo
             FROM ctacoaseguro c, companias p, empresas e, seguros s, monedas m, productos pd
            WHERE c.ccompani = p.ccompani
              AND s.cramo = pd.cramo
              AND s.cmodali = pd.cmodali
              AND s.ctipseg = pd.ctipseg
              AND s.ccolect = pd.ccolect
              AND m.cmoneda = pd.cdivisa
              AND NVL(c.cmoneda, pd.cdivisa) = pd.cdivisa
              AND m.cidioma = 8
              AND c.imovimi <> 0
              AND e.cempres(+) = c.cempres
              AND c.ctipcoa = s.ctipcoa
              AND s.ctipcoa > 0
              AND c.sseguro = s.sseguro
              AND c.cempres = 24
              --AND c.ccompani = pccompani
              AND c.sproces = psproces
              --AND c.cestado = 1 -- BUG 1896 AP 23/04/2018
              AND c.cmovimi = 99
         GROUP BY e.tempres, s.cempres, s.sseguro, c.ccompani, p.tcompani, c.ccompapr,
                  c.ctipcoa, s.cramo,
                  f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8), s.npoliza,
                  s.ncertif, NVL(c.cmoneda, s.cmoneda), m.cmonint;

      vreturn        VARCHAR2(1000);
      vsuma          FLOAT := 0;
      vsumamin       FLOAT := 0;
   BEGIN
      IF ptipo = 1 THEN
         FOR cta IN c_ctates LOOP
            vreturn := vreturn || cta.ttipcoa || ' <br>';
         END LOOP;
      END IF;

      IF ptipo = 2 THEN
         FOR cta IN c_ctates LOOP
            vreturn := vreturn || TO_CHAR(cta.isaldo, '99,999,999,999,999,999,999.99')
                       || ' <br>';
         END LOOP;
      END IF;

    IF ptipo = 3 THEN
         FOR cta IN c_ctates LOOP
            vsuma:=vsuma+cta.isaldo;
         END LOOP;
         vreturn := vreturn || TO_CHAR(vsuma, '99,999,999,999,999,999,999.99')
                       || ' <br>';
      END IF;

      RETURN vreturn;
   EXCEPTION
      WHEN OTHERS THEN
         CLOSE c_ctates;

         RETURN NULL;
   END f_detallecoaseguro;


FUNCTION f_representante_legal (psperson IN NUMBER,pdato IN NUMBER)
  RETURN VARCHAR2
  IS

  CURSOR c_representante IS
         SELECT PAC_ISQLFOR.f_dni(NULL,NULL,sperson_rel) as dni,PAC_ISQLFOR_CONF.f_per_nombre_rel(sperson_rel) AS nombre,
             PAC_ISQLFOR.f_domicilio(sperson_rel,1) as direccion,PAC_ISQLFOR.f_telefono(sperson_rel) as telefono
             FROM PER_PERSONAS_REL WHERE CTIPPER_REL = 1 AND SPERSON =psperson AND ROWNUM = 1;

        vreturn VARCHAR2(2000);
  BEGIN
      FOR rep IN c_representante LOOP
              IF pdato = 1 THEN
              vreturn:=rep.dni;
              ELSIF pdato = 2 THEN
              vreturn:=rep.nombre;
              ELSIF pdato = 3 THEN
              vreturn:=rep.direccion;
              ELSIF pdato = 4 THEN
              vreturn:=rep.telefono;
              END IF;
      END LOOP;

    RETURN nvl(vreturn, ' ');
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
  END f_representante_legal;

  FUNCTION f_grupo_cuentas(penviopers IN VARCHAR2,
                           pperson    IN NUMBER) RETURN VARCHAR2 IS

     valor   VARCHAR2(100);
     vconcat VARCHAR2(100) := NULL;

     CURSOR cuentas(pparam IN VARCHAR2) IS
        SELECT nvalpar
          FROM per_parpersonas
         WHERE cparam = pparam
           AND sperson = pperson;

  BEGIN

     IF SUBSTR(penviopers, 1, 1) = 'P'
     THEN
        valor   := 'GR_CUENTAS_PROVEED';
     ELSE
        valor   := 'GR_CUENTAS_CLIEN';
     END IF;

     FOR i IN cuentas(valor)
     LOOP
        vconcat := concat(SUBSTR(penviopers, 1, 1), lpad(i.nvalpar, 3, 0));
     END LOOP;

     IF vconcat = penviopers
     THEN
        RETURN penviopers;
     ELSIF vconcat <> penviopers AND
           vconcat IS NOT NULL
     THEN
        RETURN vconcat;
     ELSE
        RETURN penviopers;
     END IF;

  END f_grupo_cuentas;

  FUNCTION f_num_cuenta(penviopers IN VARCHAR2,
                           pperson    IN NUMBER) RETURN VARCHAR2 IS

     valor   VARCHAR2(100);
     vconcat VARCHAR2(100) := NULL;
     vdato   VARCHAR2(100);

     CURSOR cuentas(pparam IN VARCHAR2) IS
        SELECT tvalpar
          FROM per_parpersonas
         WHERE cparam = pparam
           AND sperson = pperson;

  BEGIN

     IF SUBSTR(penviopers, 1, 1) = 'P'
     THEN
        vdato   := NVL(pac_parametros.f_parempresa_t(24, 'CUENTA_PROVEED'), 0);
        valor   := 'NUM_CUENTA_PROVEED';
     ELSE
        vdato   := NVL(pac_parametros.f_parempresa_t(24, 'CUENTA_CLIEN'), 0);
        valor   := 'NUM_CUENTA_CLIEN';
     END IF;

     FOR i IN cuentas(valor)
     LOOP
        vconcat := i.tvalpar;
     END LOOP;

     IF vconcat = vdato
     THEN
        RETURN vdato;
     ELSIF vconcat <> vdato AND
           vconcat IS NOT NULL
     THEN
        RETURN vconcat;
     ELSE
        RETURN vdato;
     END IF;

  END f_num_cuenta;
--
/***************************************************
 Funcion: f_per_acre_deu 
 Nombre : Persona Deudora o Acreedora
 Parametros: 
   penviopers IN VARCHAR2 envio de persona
   pperson    IN NUMBER   sperson de la persona
   return   varchar2 sperson deudor o acreedor
 TC 464 AABC 12/02/2019  VERSION 2.0           
****************************************************/
  FUNCTION f_per_acre_deu(penviopers IN VARCHAR2,
                          pperson    IN NUMBER) RETURN VARCHAR2 IS

     valor   VARCHAR2(10);
     vcuenta VARCHAR2(2) := NULL;
     vsperson_deud   per_personas.sperson_deud %TYPE;
     vsperson_acre   per_personas.sperson_acre %TYPE;
  BEGIN
     --
     BEGIN
        --
        SELECT sperson_deud,sperson_acre
          INTO vsperson_deud,vsperson_acre
          FROM per_personas
         WHERE sperson = pperson;
        --
     EXCEPTION WHEN OTHERS THEN
        --
        NULL;
        -- 
     END;     
     --
     valor   := pac_isqlfor_conf.f_grupo_cuentas(penviopers , pperson ); 
     vcuenta := SUBSTR(penviopers, 1, 1); 
     --
     IF vcuenta = 'C' THEN
       --
       RETURN  vsperson_deud;
       --
     ELSIF VCUENTA = 'P' THEN
       --
       RETURN vsperson_acre;
       --
     ELSE      
       --
       RETURN pperson;
       --
     END IF;
     --
  END f_per_acre_deu;
--

  FUNCTION f_vias_pago(penviopers IN VARCHAR2,
                       pperson    IN NUMBER) RETURN VARCHAR2 IS

     vgrupo VARCHAR2(100);

     CURSOR vias(pparam IN VARCHAR2) IS
        SELECT tvalpar
          FROM per_parpersonas
         WHERE cparam = pparam
           AND sperson = pperson;

  BEGIN

     FOR i IN vias('VIAS_PAGO')
     LOOP
        vgrupo := i.tvalpar;
     END LOOP;

     IF vgrupo IS NULL AND
        SUBSTR(penviopers, 1, 1) = 'P'
     THEN
        RETURN 'AGHMTU';
     ELSIF vgrupo IS NULL AND
           SUBSTR(penviopers, 1, 1) = 'C'
     THEN
        RETURN 'B';
     ELSIF vgrupo IS NOT NULL
     THEN
        RETURN vgrupo;
     ELSE
        RETURN NULL;
     END IF;

     END f_vias_pago;

  /*****************************************************************
  FUNCTION f_get_prima_minima
    FunciÃ¯Â¿Â½n que trae la prima mÃ¯Â¿Â½nima establecida por sucursal:

    param IN pcempres  : CÃ¯Â¿Â½digo de la empresa
    param IN p_agente  : CÃ¯Â¿Â½digo del agente
    param IN psproduc  : CÃ¯Â¿Â½digo del producto
    param IN pcactivi  : Código de la actividad
    param IN pfbusca   : Fecha de bÃ¯Â¿Â½squeda
    return             : Prima mÃ¯Â¿Â½nima establecida
  ******************************************************************/
  FUNCTION f_get_prima_minima (
    pcempres IN NUMBER,
    pcagente IN NUMBER,
    psproduc IN NUMBER,
    pcactivi IN NUMBER,
    pfbusca  IN DATE
    ) RETURN NUMBER IS

    v_ctipage   NUMBER;
    v_fbusca    DATE := pfbusca;
    v_prima_min NUMBER := 0;
    v_padre     NUMBER;
    --bartolo 02-05-2019 iaxis-3629
    cant_preg NUMBER := 0;
    PRIMINIMA NUMBER := 0;
    nnumide   NUMBER := 0;
    --bartolo 02-05-2019 iaxis-3629
    --Ini 4082 --ECP -- 10/10/2019
    v_cpregun_2912 NUMBER:=2912;
    --Fin 4082 --ECP -- 10/10/2019
   BEGIN

    IF pcempres IS NULL  OR pcagente IS NULL THEN
      p_tab_error(f_sysdate, f_user, 'pac_isqlfor_conf.f_get_prima_minima', 1, 'Parametros incorrectos', '');
      RETURN NULL;
    END IF;

    IF v_fbusca IS NULL THEN
      v_fbusca:=trunc(f_sysdate);
    END IF;

    SELECT ctipage, cpadre
      INTO v_ctipage, v_padre
      FROM redcomercial
     WHERE cagente = pcagente
       AND cempres = pcempres
       AND fmovini <= v_fbusca
       AND (fmovfin > v_fbusca OR fmovfin IS NULL);
   IF v_ctipage in (0,1,2,3) THEN
      v_prima_min := pac_subtablas.f_vsubtabla(-1,8000011,333,1, psproduc, pcagente, pcactivi);
    ELSE
      v_prima_min := pac_subtablas.f_vsubtabla(-1,8000011,333,1, psproduc, v_padre, pcactivi);
    END IF;
    
    -- bartolo herrera 26-04-2019 inicio
    
    SELECT COUNT(*)
      INTO cant_preg
      FROM estpregunpolseg
     WHERE sseguro = pac_iax_produccion.poliza.det_poliza.sseguro
       AND nmovimi = pac_iax_produccion.poliza.det_poliza.nmovimi
       AND cpregun = 2913;
         
     IF cant_preg > 0 THEN -- si escogio un convenio
      FOR vrie IN pac_iax_produccion.poliza.det_poliza.riesgos.first .. pac_iax_produccion.poliza.det_poliza.riesgos.last LOOP
        FOR vaseg IN pac_iax_produccion.poliza.det_poliza.riesgos(vrie).riesgoase.first .. pac_iax_produccion.poliza.det_poliza.riesgos(vrie).riesgoase.last LOOP
          nnumide := pac_iax_produccion.poliza.det_poliza.riesgos(vrie).riesgoase(vaseg).nnumide;
        END LOOP;
      END LOOP;
          IF pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
         THEN
            IF pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0
            THEN
               FOR i IN
                  pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST
               LOOP
                  --Ini IAXIS-4082 -- ECP -- 10/10/2019
                  IF v_cpregun_2912 =
                        pac_iax_produccion.poliza.det_poliza.preguntas (i).cpregun
                  THEN
                     nnumide := pac_iax_produccion.poliza.det_poliza.preguntas (i).trespue;
                  END IF;
               --Fin IAXIS-4082 -- ECP -- 10/10/2019
               END LOOP;
            END IF;
         END IF;   
      
      
      SELECT nval2
        INTO priminima
        FROM sgt_subtabs_det
       WHERE csubtabla = 9000007
         AND ccla1 = psproduc
         AND ccla2 = pcactivi
         AND ccla3 = nnumide
         AND rownum <= 1;   
                
      IF PRIMINIMA > 0 THEN
        v_prima_min := PRIMINIMA;
      END IF;
          
    END IF;
     
    -- bartolo herrera 26-04-2019 fin
   
    RETURN v_prima_min;

  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'pac_isqlfor_conf.f_get_prima_minima', 2, SQLCODE, SQLERRM||'cant_preg-->'||cant_preg||' psproduc-->'||psproduc||' pcactivi-->'||pcactivi||' nnumide-->'||nnumide||'priminima-->'||priminima||'v_prima_min->'||v_prima_min||' pcagente-->'||pcagente||'v_padre-->'||v_padre);
      RETURN NULL;

  END f_get_prima_minima;

  -- Ini TCS_309 - ACL - 14/03/2019 
  /*************************************************************************
  FUNCTION f_cal_cuota
    FunciÃ¯Â¿Â½n que trae el valor de cuota de pagare recobros:

    param IN pscontgar  : NÃ¯Â¿Â½mero de contragarantia
    return             : Valor establecido
   *************************************************************************/
   FUNCTION f_cal_cuota(pscontgar IN NUMBER)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_cal_cuota';
      vparam   VARCHAR2(500) := 'pscontgar: ' ||
                                pscontgar;
      --
      v_valor        NUMBER;
      v_calculo1     NUMBER;
      v_calculo2     NUMBER;
      v_cuotas       NUMBER;
      v_porcentaje   NUMBER;

   BEGIN
        BEGIN                               
            select round (p.ivalor * (100 - c.iinteres))/100
            into v_valor
                   from ctgar_contragarantia p, ctgar_det c
                    WHERE p.scontgar = c.scontgar
            AND c.scontgar = pscontgar
            and p.nmovimi = (select max (t.nmovimi)
                                from ctgar_contragarantia t
                                where t.scontgar = pscontgar)
            and c.nmovimi = (select max (g.nmovimi)
                                from ctgar_det g
                                where g.scontgar = pscontgar);
         --
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_valor := 0;
        END;

        select c.nplazo, c.porcentaje 
            into v_cuotas, v_porcentaje
         from ctgar_det c
         where c.scontgar = pscontgar
         and c.nmovimi = (select max (g.nmovimi)
                                from ctgar_det g
                                where g.scontgar = pscontgar);

         v_calculo1 := (v_valor * v_porcentaje);

        IF v_valor <> 0 THEN
            v_calculo2 := F_round (v_calculo1 / v_cuotas);
        ELSE
            v_calculo2 := 0;
        END IF;
      --
      RETURN v_calculo2;
      --
   END f_cal_cuota; 

/*************************************************************************
  FUNCTION f_letras_cuota
    FunciÃ¯Â¿Â½n que trae el valor en letras de la cuota de pagare recobros:

    param IN pscontgar  : NÃ¯Â¿Â½mero de contragarantia
    return             : Valor establecido
   *************************************************************************/
   FUNCTION f_letras_cuota(pscontgar IN NUMBER)
      RETURN VARCHAR2 IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_letras_cuota';
      vparam   VARCHAR2(500) := 'pscontgar: ' ||
                                pscontgar;
      --
      v_valor        NUMBER;
      v_calculo1     NUMBER;
      v_calculo2     NUMBER;
      v_cuotas       NUMBER;
      v_porcentaje   NUMBER;
      v_letras       VARCHAR2(2000);
      v_letras_aux   VARCHAR2(2000);

   BEGIN
        BEGIN                               
            select round (p.ivalor * (100 - c.iinteres))/100
            into v_valor
                   from ctgar_contragarantia p, ctgar_det c
                    WHERE p.scontgar = c.scontgar
            AND c.scontgar = pscontgar
            and p.nmovimi = (select max (t.nmovimi)
                                from ctgar_contragarantia t
                                where t.scontgar = pscontgar)
            and c.nmovimi = (select max (g.nmovimi)
                                from ctgar_det g
                                where g.scontgar = pscontgar);
         --
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_valor := 0;
        END;

        select c.nplazo, c.porcentaje 
            into v_cuotas, v_porcentaje
         from ctgar_det c
         where c.scontgar = pscontgar
         and c.nmovimi = (select max (g.nmovimi)
                                from ctgar_det g
                                where g.scontgar = pscontgar);

         v_calculo1 := (v_valor * v_porcentaje);

        IF v_valor <> 0 THEN
            v_calculo2 := F_round (v_calculo1 / v_cuotas);
        ELSE
            v_calculo2 := 0;
        END IF;

        IF v_calculo2 <> 0 THEN
        v_letras := f_numlet (8,v_calculo2 ,null,v_letras_aux);
        END IF;
        --
      RETURN v_letras_aux;
      --
   END f_letras_cuota; 

/*************************************************************************
  FUNCTION f_letras_valor1
    FunciÃ¯Â¿Â½n que trae el valor en letras del valor 1 de pagare recobros:

    param IN pscontgar  : NÃ¯Â¿Â½mero de contragarantia
    return             : Valor establecido
   *************************************************************************/
   FUNCTION f_letras_valor1(pscontgar IN NUMBER)
      RETURN VARCHAR2 IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_letras_valor1';
      vparam   VARCHAR2(500) := 'pscontgar: ' ||
                                pscontgar;
      --
      v_valor        NUMBER;
      v_valor1       NUMBER;
      v_letras       VARCHAR2(2000);
      v_letras_aux   VARCHAR2(2000);

   BEGIN
        BEGIN                               
        select c.ivalor
            into v_valor
         from ctgar_contragarantia c
         where c.scontgar = pscontgar
         and c.nmovimi = (select max (g.nmovimi)
                                from ctgar_contragarantia g
                                where g.scontgar = pscontgar);
         --
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_valor := 0;
        END;

        IF v_valor <> 0 THEN
        v_valor1 := F_round (v_valor);
        v_letras := f_numlet (8,v_valor1 ,null,v_letras_aux);
        ELSE
        v_letras := ' ';
        END IF;
        --
      RETURN v_letras_aux;
      --
   END f_letras_valor1; 

   /*************************************************************************
  FUNCTION f_letras_valor2
    FunciÃ¯Â¿Â½n que trae el valor en letras del valor 2 de pagare recobros:

    param IN pscontgar  : NÃ¯Â¿Â½mero de contragarantia
    return             : Valor establecido
   *************************************************************************/
   FUNCTION f_letras_valor2(pscontgar IN NUMBER)
      RETURN VARCHAR2 IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_letras_valor2';
      vparam   VARCHAR2(500) := 'pscontgar: ' ||
                                pscontgar;
      --
      v_valor        NUMBER;
      v_valor1       NUMBER;
      v_letras       VARCHAR2(2000);
      v_letras_aux   VARCHAR2(2000);

   BEGIN
        BEGIN                               
        select round (p.ivalor * c.iinteres)/100
        into v_valor
                   from ctgar_contragarantia p, ctgar_det c
                    WHERE p.scontgar = c.scontgar
            AND c.scontgar = pscontgar
            and p.nmovimi = (select max (t.nmovimi)
                                from ctgar_contragarantia t
                                where t.scontgar = pscontgar)
            and c.nmovimi = (select max (g.nmovimi)
                                from ctgar_det g
                                where g.scontgar = pscontgar);
         --
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_valor := 0;
        END;

        IF v_valor <> 0 THEN
        v_valor1 := F_round (v_valor);
        v_letras := f_numlet (8,v_valor1 ,null,v_letras_aux);
        END IF;
        --
      RETURN v_letras_aux;
      --
   END f_letras_valor2; 

      /*************************************************************************
  FUNCTION f_letras_valor3
    FunciÃ¯Â¿Â½n que trae el valor en letras del valor 3 de pagare recobros:

    param IN pscontgar  : NÃ¯Â¿Â½mero de contragarantia
    return             : Valor establecido
   *************************************************************************/
   FUNCTION f_letras_valor3(pscontgar IN NUMBER)
      RETURN VARCHAR2 IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_letras_valor3';
      vparam   VARCHAR2(500) := 'pscontgar: ' ||
                                pscontgar;
      --
      v_valor        NUMBER;
      v_valor1       NUMBER;
      v_letras       VARCHAR2(2000);
      v_letras_aux   VARCHAR2(2000);

   BEGIN
        BEGIN                               
       select round (p.ivalor * (100 - c.iinteres))/100
        into v_valor
                   from ctgar_contragarantia p, ctgar_det c
                    WHERE p.scontgar = c.scontgar
            AND c.scontgar = pscontgar
            and p.nmovimi = (select max (t.nmovimi)
                                from ctgar_contragarantia t
                                where t.scontgar = pscontgar)
            and c.nmovimi = (select max (g.nmovimi)
                                from ctgar_det g
                                where g.scontgar = pscontgar);
         --
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_valor := 0;
        END;

        IF v_valor <> 0 THEN
        v_valor1 := F_round (v_valor);
        v_letras := f_numlet (8,v_valor1 ,null,v_letras_aux);
        END IF;
        --
      RETURN v_letras;
      --
   END f_letras_valor3; 
  -- Fin TCS_309 - ACL - 14/03/2019 

  -- Ini TCS_309 - ACL - 18/03/2019   
  /*************************************************************************
    FUNCTION f_letras_plazo
    FunciÃ¯Â¿Â½n que trae el valor en letras del nÃ¯Â¿Â½mero de cuotas:

    param IN pscontgar  : NÃ¯Â¿Â½mero de contragarantia
    return             : Valor establecido
   *************************************************************************/
   FUNCTION f_letras_plazo(pscontgar IN NUMBER)
      RETURN VARCHAR2 IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_letras_plazo';
      vparam   VARCHAR2(500) := 'pscontgar: ' ||
                                pscontgar;
      --
      v_nplazo       NUMBER;
      v_valor1       NUMBER;
      v_letras       VARCHAR2(2000);
      v_letras_aux   VARCHAR2(2000);

   BEGIN
        BEGIN                               
       select c.nplazo
        into v_nplazo
                   from ctgar_det c
                    WHERE c.scontgar = pscontgar
            and c.nmovimi = (select max (g.nmovimi)
                                from ctgar_det g
                                where g.scontgar = pscontgar);
         --
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_nplazo := 0;
        END;

        IF v_nplazo <> 0 THEN
        v_valor1 := F_round (v_nplazo);
        v_letras := f_numlet (8,v_valor1 ,null,v_letras_aux);
        END IF;
        --
      RETURN v_letras;
      --
   END f_letras_plazo; 
   -- Fin TCS_309 - ACL - 18/03/2019 

--Ini TCS_19  - ACL - 20/03/2019
 /*************************************************************************
    FUNCTION f_intermediario
    FunciÃ¯Â¿Â½n que trae el valor en letras del nÃ¯Â¿Â½mero de cuotas:

    param IN pscontgar  : NÃ¯Â¿Â½mero de contragarantia
    return             : Valor establecido
   *************************************************************************/
    FUNCTION f_intermediario(pscontgar IN NUMBER)
      RETURN VARCHAR2 IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_intermediario';
      vparam   VARCHAR2(500) := 'pscontgar: ' ||
                                pscontgar;
      --
      v_ctipper      NUMBER;
      v_nnumide      VARCHAR2(15);
      v_nombre       VARCHAR2(2000); 
      v_rlegal       VARCHAR2(5000);

   BEGIN  
        select p.CTIPPER 
        into v_ctipper
        from per_personas p
        where p.sperson = (select c.sperson
        from per_contragarantia c
        WHERE c.scontgar = pscontgar);

        IF v_ctipper = 1 THEN
        select pe.nnumide
            into v_nnumide
                        from per_personas pe
                where pe.sperson = (select c.sperson
                         from per_contragarantia c
                            WHERE c.scontgar = pscontgar);   

         SELECT pd.tapelli1
                            || Decode(pd.tapelli1,
                                      NULL, NULL,
                                      ' ')
                            || pd.tapelli2
                            || Decode(pd.tapelli1
                                             || pd.tapelli2,
                                      NULL, NULL,
                                      Decode(pd.tnombre,
                                             NULL, NULL,
                                             pd.tnombre1 || ' ' || pd.tnombre2))
                INTO v_nombre                              
                  FROM   per_detper pd
                  WHERE  pd.sperson = (select c.sperson
            from per_contragarantia c
            WHERE c.scontgar = pscontgar);
        ELSE
            select pe.nnumide
                into v_nnumide
                            from per_personas pe
                    where pe.sperson = (select sr.sperson_rel from per_personas_rel sr
                    where sr.sperson = (SELECT p.sperson FROM per_contragarantia p
                        WHERE p.scontgar = pscontgar));    

            SELECT pd.tapelli1
                                || Decode(pd.tapelli1,
                                          NULL, NULL,
                                          ' ')
                                || pd.tapelli2
                                || Decode(pd.tapelli1
                                                 || pd.tapelli2,
                                          NULL, NULL,
                                          Decode(pd.tnombre,
                                                 NULL, NULL,
                                                 pd.tnombre1 || ' ' || pd.tnombre2))
                  INTO v_nombre                               
                  FROM   per_detper pd
                  WHERE  pd.sperson = (select sr.sperson_rel from per_personas_rel sr
                    where sr.sperson = (SELECT p.sperson FROM per_contragarantia p
                        WHERE p.scontgar = pscontgar));
      END IF;
      IF v_nnumide IS NOT NULL THEN
        v_rlegal := 'Nosotros ' || v_nombre || ' mayor de edad, identificado(a) con la cedula de ciudadania No. ' || v_nnumide;      
        ELSE 
        v_rlegal := ' ';
        END IF;
        --
      RETURN v_rlegal;
      --
   END f_intermediario; 

     /*************************************************************************
    FUNCTION f_ciud_exp_inter
    FunciÃ¯Â¿Â½n que trae el valor en letras del nÃ¯Â¿Â½mero de cuotas:

    param IN pscontgar  : NÃ¯Â¿Â½mero de contragarantia
    return             : Valor establecido
   *************************************************************************/
      FUNCTION f_ciud_exp_rp(pscontgar IN NUMBER)
      RETURN VARCHAR2 IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_ciud_exp_rp';
      vparam   VARCHAR2(500) := 'pscontgar: ' ||
                                pscontgar;
      --
      v_ctipper     NUMBER;
      v_ciudad      VARCHAR2(100);
      v_rlegal      VARCHAR2(5000);

   BEGIN  
        select p.CTIPPER 
        into v_ctipper
        from per_personas p
        where p.sperson = (select c.sperson
        from per_contragarantia c
        WHERE c.scontgar = pscontgar);

        IF v_ctipper = 1 THEN
        select po.tpoblac 
         into v_ciudad
         from poblaciones po where po.cpoblac = (SELECT id.cciudadexp
                   FROM per_identificador id
                  WHERE id.sperson = (select c.sperson
                            from per_contragarantia c
                            WHERE c.scontgar = pscontgar))
                  and po.cprovin = (SELECT id.cdepartexp
                   FROM per_identificador id
                  WHERE id.sperson = (select c.sperson
        from per_contragarantia c
        WHERE c.scontgar = pscontgar));
        ELSE
        select po.tpoblac 
         into v_ciudad
         from poblaciones po where po.cpoblac = (SELECT id.cciudadexp
                   FROM per_identificador id
                  WHERE id.sperson = (select sr.sperson_rel from per_personas_rel sr
                where sr.sperson = (SELECT p.sperson FROM per_contragarantia p
                    WHERE p.scontgar = pscontgar)))
                  and po.cprovin = (SELECT id.cdepartexp
                   FROM per_identificador id
                  WHERE id.sperson = (select sr.sperson_rel from per_personas_rel sr
                where sr.sperson = (SELECT p.sperson FROM per_contragarantia p
                    WHERE p.scontgar = pscontgar))); 
    END IF;

      IF v_ciudad IS NOT NULL THEN
        v_rlegal := ' expedida en ' || v_ciudad;      
        ELSE 
        v_rlegal := ' ';
        END IF;
        --
      RETURN v_rlegal;
      --
   END f_ciud_exp_rp; 

   /*************************************************************************
    FUNCTION f_domic_inter
    FunciÃ¯Â¿Â½n que trae el valor en letras del nÃ¯Â¿Â½mero de cuotas:

    param IN pscontgar  : NÃ¯Â¿Â½mero de contragarantia
    return             : Valor establecido
   *************************************************************************/ 
    FUNCTION f_domic_rp(pscontgar IN NUMBER)
      RETURN VARCHAR2 IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_domic_rp';
      vparam   VARCHAR2(500) := 'pscontgar: ' ||
                                pscontgar;
      --
      v_ctipper     NUMBER;
      v_ciudad      VARCHAR2(100);
      v_rlegal      VARCHAR2(5000);

   BEGIN 
   select p.CTIPPER 
        into v_ctipper
        from per_personas p
        where p.sperson = (select c.sperson
        from per_contragarantia c
        WHERE c.scontgar = pscontgar);

        IF v_ctipper = 1 THEN
            SELECT max(tpoblac)
            into v_ciudad
            FROM per_direcciones pr, poblaciones po
           WHERE pr.sperson = (select c.sperson
            from per_contragarantia c
            WHERE c.scontgar = pscontgar)
               AND pr.cdomici = (select max(cdomici)
                 from per_direcciones
                 where sperson = (select c.sperson
            from per_contragarantia c
            WHERE c.scontgar = pscontgar))
                 AND pr.cprovin = po.cprovin
                 AND pr.cpoblac = po.cpoblac;
         ELSE
             select po.tpoblac 
                into v_ciudad
             from poblaciones po where po.cprovin = (SELECT * FROM (SELECT dir.cprovin FROM per_direcciones dir
                                            where dir.sperson = (select sr.sperson_rel from per_personas_rel sr
                                                where sr.sperson = (SELECT p.sperson FROM per_contragarantia p
                                                                     WHERE p.scontgar = pscontgar))
                                ORDER BY dir.cdomici asc) WHERE ROWNUM = 1)
                                and po.cpoblac = (SELECT * FROM (SELECT dir.cpoblac FROM per_direcciones dir
                                where dir.sperson = (select sr.sperson_rel from per_personas_rel sr
                                    where sr.sperson = (SELECT p.sperson FROM per_contragarantia p
                                                         WHERE p.scontgar = pscontgar))
                                 ORDER BY dir.cdomici asc) WHERE ROWNUM = 1);
         END IF;

      IF v_ciudad IS NOT NULL THEN
        v_rlegal := ', con domicilio en la ciudad de ' || v_ciudad;      
        ELSE 
        v_rlegal := ' ';
        END IF;
        --
      RETURN v_rlegal;
      --
   END f_domic_rp; 
-- Fin TCS_19 - ACL - 20/03/2019 
-- Ini ACL - 21/03/2019 TCS_19
   /*************************************************************************
    FUNCTION f_codeudor
    FunciÃ¯Â¿Â½n que trae el valor en letras del nÃ¯Â¿Â½mero de cuotas:

    param IN pscontgar  : NÃ¯Â¿Â½mero de contragarantia
    return             : Valor establecido
   *************************************************************************/   
      FUNCTION f_codeudor(pscontgar IN NUMBER)
      RETURN VARCHAR2 IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_codeudor';
      vparam   VARCHAR2(500) := 'pscontgar: ' ||
                                pscontgar;
      --
      v_ctipper      NUMBER;
      v_nnumide      VARCHAR2(15);
      v_nombre       VARCHAR2(2000); 
      v_rlegal       VARCHAR2(5000);

   BEGIN  
        select p.CTIPPER 
        into v_ctipper
        from per_personas p
        where p.sperson = (select ct.sperson
                                    from ctgar_codeudor ct
                                    where ct.scontgar = pscontgar);

        IF v_ctipper = 1 THEN
        select pe.nnumide
          into v_nnumide
                        from per_personas pe
                where pe.sperson = (select ct.sperson
                                    from ctgar_codeudor ct
                                    where ct.scontgar = pscontgar);

         SELECT pd.tapelli1
                            || Decode(pd.tapelli1, NULL, NULL, ' ')
                            || pd.tapelli2
                            || Decode(pd.tapelli1 || pd.tapelli2,
                                      NULL, NULL,
                                      Decode(pd.tnombre, NULL, NULL, pd.tnombre1 || ' ' || pd.tnombre2))
            INTO v_nombre 
              FROM   per_detper pd
              WHERE  pd.sperson = (select ct.sperson
                                    from ctgar_codeudor ct
                                    where ct.scontgar = pscontgar);
        ELSE
             select pe.nnumide
              into v_nnumide
                        from per_personas pe
                where pe.sperson = (select sr.sperson_rel from per_personas_rel sr
                where sr.sperson = (select ct.sperson
                                    from ctgar_codeudor ct
                                    where ct.scontgar = pscontgar));

            SELECT pd.tapelli1
                            || Decode(pd.tapelli1,
                                      NULL, NULL,
                                      ' ')
                            || pd.tapelli2
                            || Decode(pd.tapelli1
                                             || pd.tapelli2,
                                      NULL, NULL,
                                      Decode(pd.tnombre,
                                             NULL, NULL,
                                             pd.tnombre1 || ' ' || pd.tnombre2))
             INTO v_nombre 
              FROM   per_detper pd
              WHERE  pd.sperson = (select sr.sperson_rel from per_personas_rel sr
                                    where sr.sperson = (select ct.sperson
                                        from ctgar_codeudor ct
                                        where ct.scontgar = pscontgar));
      END IF;
      IF v_nnumide IS NOT NULL THEN
        v_rlegal := ', y ' || v_nombre || ' mayor de edad, identificado(a) con la cedula de ciudadania No. ' || v_nnumide;      
        ELSE 
        v_rlegal := ' ';
        END IF;
        --
      RETURN v_rlegal;
      --
   END f_codeudor; 

     /*************************************************************************
    FUNCTION f_ciud_exp_cod
    FunciÃ¯Â¿Â½n que trae el valor en letras del nÃ¯Â¿Â½mero de cuotas:

    param IN pscontgar  : NÃ¯Â¿Â½mero de contragarantia
    return             : Valor establecido
   *************************************************************************/
      FUNCTION f_ciud_exp_cod(pscontgar IN NUMBER)
      RETURN VARCHAR2 IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_ciud_exp_cod';
      vparam   VARCHAR2(500) := 'pscontgar: ' ||
                                pscontgar;
      --
      v_ctipper     NUMBER;
      v_ciudad      VARCHAR2(100);
      v_rlegal      VARCHAR2(5000);

   BEGIN  
       select p.CTIPPER 
        into v_ctipper
        from per_personas p
        where p.sperson = (select ct.sperson
                                    from ctgar_codeudor ct
                                    where ct.scontgar = pscontgar);

        IF v_ctipper = 1 THEN
        select po.tpoblac 
          into v_ciudad
          from poblaciones po where po.cpoblac = (SELECT id.cciudadexp
                   FROM per_identificador id
                  WHERE id.sperson = (select ct.sperson
                                    from ctgar_codeudor ct
                                    where ct.scontgar = 3541))
                  and po.cprovin = (SELECT id.cdepartexp
                   FROM per_identificador id
                  WHERE id.sperson = (select ct.sperson
                                    from ctgar_codeudor ct
                                    where ct.scontgar = pscontgar));
        ELSE
        select po.tpoblac 
         into v_ciudad
         from poblaciones po where po.cpoblac = (SELECT id.cciudadexp
                   FROM per_identificador id
                  WHERE id.sperson = (select sr.sperson_rel from per_personas_rel sr
                where sr.sperson = (select ct.sperson
                                    from ctgar_codeudor ct
                                    where ct.scontgar = pscontgar)))
                  and po.cprovin = (SELECT id.cdepartexp
                   FROM per_identificador id
                  WHERE id.sperson = (select sr.sperson_rel from per_personas_rel sr
                where sr.sperson = (select ct.sperson
                                    from ctgar_codeudor ct
                                    where ct.scontgar = pscontgar))); 
    END IF;

      IF v_ciudad IS NOT NULL THEN
        v_rlegal := ' expedida en ' || v_ciudad;      
        ELSE 
        v_rlegal := ' ';
        END IF;
        --
      RETURN v_rlegal;
      --
   END f_ciud_exp_cod; 

   /*************************************************************************
    FUNCTION f_domic_cod
    FunciÃ¯Â¿Â½n que trae el valor en letras del nÃ¯Â¿Â½mero de cuotas:

    param IN pscontgar  : NÃ¯Â¿Â½mero de contragarantia
    return             : Valor establecido
   *************************************************************************/ 
    FUNCTION f_domic_cod(pscontgar IN NUMBER)
      RETURN VARCHAR2 IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_domic_cod';
      vparam   VARCHAR2(500) := 'pscontgar: ' ||
                                pscontgar;
      --
      v_ctipper     NUMBER;
      v_ciudad      VARCHAR2(100);
      v_rlegal      VARCHAR2(5000);

   BEGIN 
    select p.CTIPPER 
        into v_ctipper
        from per_personas p
        where p.sperson = (select ct.sperson
                                    from ctgar_codeudor ct
                                    where ct.scontgar = pscontgar); 

        IF v_ctipper = 1 THEN
            select po.tpoblac 
                into v_ciudad
                from poblaciones po where po.cprovin = (SELECT * FROM (SELECT dir.cprovin FROM per_direcciones dir
                                                                    where dir.sperson = (select ct.sperson
                                    from ctgar_codeudor ct
                                    where ct.scontgar = pscontgar)
                                ORDER BY dir.cdomici asc) WHERE ROWNUM = 1)
                                and po.cpoblac = (SELECT * FROM (SELECT dir.cpoblac FROM per_direcciones dir
                                where dir.sperson = (select ct.sperson
                                    from ctgar_codeudor ct
                                    where ct.scontgar = pscontgar)
                                ORDER BY dir.cdomici asc) WHERE ROWNUM = 1);
         ELSE
             select po.tpoblac 
                into v_ciudad
             from poblaciones po where po.cprovin = (SELECT * FROM (SELECT dir.cprovin FROM per_direcciones dir
                                            where dir.sperson = (select sr.sperson_rel from per_personas_rel sr
                                                where sr.sperson = (select ct.sperson
                                    from ctgar_codeudor ct
                                    where ct.scontgar = pscontgar))
                                ORDER BY dir.cdomici asc) WHERE ROWNUM = 1)
                                and po.cpoblac = (SELECT * FROM (SELECT dir.cpoblac FROM per_direcciones dir
                                where dir.sperson = (select sr.sperson_rel from per_personas_rel sr
                                    where sr.sperson = (select ct.sperson
                                    from ctgar_codeudor ct
                                    where ct.scontgar = pscontgar))
                                 ORDER BY dir.cdomici asc) WHERE ROWNUM = 1);
         END IF;

      IF v_ciudad IS NOT NULL THEN
        v_rlegal := ', con domicilio en la ciudad de ' || v_ciudad;      
        ELSE 
        v_rlegal := ' ';
        END IF;
        --
      RETURN v_rlegal;
      --
   END f_domic_cod; 
-- Fin ACL - 21/03/2019 TCS_19

   -- Cambios de IAXIS-3286 : Start
  /*************************************************************************
    FUNCTION f_roles_persona_Bridger
    FunciÃ¯Â¿Â½n que trae el vÃ¯Â¿Â½nculo del tercero:

    param
     IN psperson     : NÃ¯Â¿Â½mero de persona
     IN pctipper_rel : tipo de relacion para persona
    return           : El vÃ¯Â¿Â½nculo del tercero
   *************************************************************************/ 

  FUNCTION f_roles_persona_Bridger(
    psperson IN NUMBER,
    pctipper_rel in number
  ) RETURN VARCHAR2
  IS
    vtipo NUMBER := 0;
    vroles VARCHAR2(2000);
    vrelacionRole VARCHAR2(2000);
  BEGIN

    select count(*) into vtipo
      from tomadores where sperson = psperson;

    if vtipo > 0 then
      vroles := vroles || 'Tomador';
    end if;

    select count(*)into vtipo
      from asegurados where sperson = psperson;

    if vtipo >0 then
      if vroles != ' ' then
        vroles := vroles || ' - ';
      end if;
      vroles := vroles || 'Asegurado';
    end if;

    if pctipper_rel is not null then
      select d.tatribu
        into vrelacionRole
        from detvalores d
       where d.cidioma = 8
         and d.catribu = pctipper_rel
         and d.cvalor = 1037;

     if vroles != ' ' then
        vroles := vroles || ' - ';
      end if;
      vroles := vroles || vrelacionRole;
    end if;

    RETURN vroles;

  END f_roles_persona_Bridger;
 -- Cambios de IAXIS-3286 : End

 -- Ini IAXIS-2136 - ACL - 28/03/2019
  /*************************************************************************
    FUNCTION f_documento_nit
    Funcion que retorna el numero de documento de identidad con o sin digiro de verificacion si aplica

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/    
      FUNCTION f_documento_nit(
      p_sperson IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      v_dades        VARCHAR2(200);
      v_ctipide      NUMBER;
   BEGIN
      IF p_sperson IS NULL THEN
         RETURN NULL;   
      ELSE
         BEGIN
            IF NVL(p_mode, 'POL') = 'EST' THEN
               SELECT p.ctipide
                 INTO v_ctipide
                 FROM estper_personas p
                WHERE p.sperson = p_sperson;
            ELSE
               SELECT p.ctipide
                 INTO v_ctipide
                 FROM per_personas p
                WHERE p.sperson = p_sperson;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      END IF;

    IF v_ctipide = 37 THEN
        SELECT substr ((pac_isqlfor.f_dades_persona(p_sperson,1,8)), 1, length (pac_isqlfor.f_dades_persona(p_sperson,1,8)) - 1) 
        INTO v_dades
        FROM DUAL;
    ELSE 
        SELECT (pac_isqlfor.f_dades_persona(p_sperson,1,8))
        INTO v_dades
        FROM DUAL;
    END IF;
      RETURN v_dades;
   END f_documento_nit;

  /*************************************************************************
    FUNCTION f_dig_verif_nit
    Funcion que retorna el digito de verificacion cuando es NIT 

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/ 
    FUNCTION f_dig_verif_nit(
      p_sperson IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 IS
      v_dades        VARCHAR2(200);
      v_ctipide      NUMBER;
   BEGIN
      IF p_sperson IS NULL THEN
         RETURN NULL;   
      ELSE
         BEGIN
            IF NVL(p_mode, 'POL') = 'EST' THEN
               SELECT p.ctipide
                 INTO v_ctipide
                 FROM estper_personas p
                WHERE p.sperson = p_sperson;
            ELSE
               SELECT p.ctipide
                 INTO v_ctipide
                 FROM per_personas p
                WHERE p.sperson = p_sperson;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      END IF;

    IF v_ctipide = 37 THEN
        select substr ((pac_isqlfor.f_dades_persona(p_sperson,1,8)), 10, 1)
        INTO v_dades
        FROM DUAL;
    ELSE 
       v_dades := NULL; 
    END IF;
      RETURN v_dades;
   END f_dig_verif_nit;

  /*************************************************************************
    FUNCTION f_trm_caratula
    Funcion que retorna TRM caratula de poliza

    param IN psseguro  : identificador unico
    param IN pnmovimi  : numero de movimiento
    return             : Valor establecido
   *************************************************************************/     
    FUNCTION f_trm_caratula(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER)
      RETURN NUMBER IS 
      v_moneda     NUMBER;
      v_desmon     VARCHAR2(10);
      v_itasa      NUMBER;
      v_sproduc    NUMBER;
   BEGIN
    IF p_sseguro IS NULL THEN
         RETURN NULL;   
    ELSE
        select s.cmoneda, s.sproduc
            into v_moneda, v_sproduc
        from seguros s
        where s.sseguro = p_sseguro;
    END IF;

    --IAXIS 2136 - ROQ - 23/07 - Correción BUG en v_desmon
    IF v_moneda IS NULL THEN
     v_desmon := 8;
    ELSE 
     v_desmon := v_moneda;
    END IF;

    IF v_desmon IS NOT NULL THEN
        select et.itasa
        into v_itasa
        from eco_tipocambio et
        where et.cmondes = (select m.cmonint
                            from monedas m
                            where m.cmoneda = v_desmon
                            and m.cidioma = 8)
        and et.cmonori = (select m.cmonint
                            from monedas m, productos p
                            where p.sproduc = v_sproduc
                            and p.cdivisa = m.cmoneda
                            and m.cidioma = 8)
        and trunc(et.fcambio) = (select trunc(m.fmovimi)
                            from movseguro m
                            where m.sseguro = p_sseguro
                            and m.nmovimi = p_nmovimi);
    ELSE 
        v_itasa := 1;
    END IF;

     RETURN v_itasa;
     END f_trm_caratula;

  /*************************************************************************
    FUNCTION f_texto_clausula
    Funcion que retorna texto de caratula

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/ 
        FUNCTION f_texto_clausula ( 
        psseguro   IN NUMBER ) 
    RETURN VARCHAR2 IS
    v_texto_aux    VARCHAR2(28000);
    v_texto        VARCHAR2(30000);
    v_texto_clau   VARCHAR2 (600);
    v_clau         VARCHAR2(20);
    v_clau_t       VARCHAR2(20); 
    v_clau_r       VARCHAR2(20); 
    v_activi       NUMBER;
    v_activi_tex   NUMBER;
    v_sproduc      NUMBER;
    BEGIN
        SELECT S.CACTIVI, S.SPRODUC
         INTO v_activi, v_sproduc
        FROM SEGUROS S
         WHERE s.sseguro = psseguro;

        IF v_activi IS NULL THEN
          v_activi_tex := 0;
        ELSE 
          v_activi_tex := v_activi;
         END IF; 

        SELECT
            LISTAGG(
                texto || chr(13)   -- IAXIS-3635 - ACL - 23/04/2019 Ajuste a espacios
            ) WITHIN GROUP(ORDER BY producto_texto_jspr.orden)
        INTO v_texto_aux
        FROM producto_texto_jspr
            JOIN texto_jspr ON producto_texto_jspr.id_texto = texto_jspr.id
        WHERE sproduc = (SELECT S.SPRODUC
                    FROM SEGUROS S
                    WHERE S.SSEGURO = psseguro)
            AND cactivi = v_activi_tex;

  
    IF v_sproduc IN ( 80010, 80011, 80001, 80012, 80009) THEN  
                        
            v_clau := pac_isqlfor_conf.f_tex_clausulado (psseguro);
            v_texto := v_texto_aux || 'EL PRESENTE CONTRATO SE RIGE POR LAS CONDICIONES GENERALES Y PARTICULARES INCLUIDAS EN LA FORMA ' || v_clau || ' ADJUNTA.';
                  
      RETURN v_texto;
              
            
   ELSIF v_sproduc IN (80003, 80002) AND v_activi IN (0,3) THEN  
      
          
        SELECT
            LISTAGG(
                texto || chr(13)   -- IAXIS-3635 - ACL - 23/04/2019 Ajuste a espacios
            ) WITHIN GROUP(ORDER BY producto_texto_jspr.orden)
        INTO v_texto_aux
        FROM producto_texto_jspr
            JOIN texto_jspr ON producto_texto_jspr.id_texto = texto_jspr.id
        WHERE sproduc = (SELECT S.SPRODUC
                    FROM SEGUROS S
                    WHERE S.SSEGURO = psseguro)
            AND cactivi = v_activi_tex;
            
            v_clau_t := pac_isqlfor_conf.f_tex_clausulado (psseguro);
--I.R.D IAXIS-5426
   
      RETURN v_texto_aux || 'EL PRESENTE CONTRATO SE RIGE POR LAS CONDICIONES GENERALES Y PARTICULARES INCLUIDAS EN LA FORMA ' || v_clau_t || ' ADJUNTA.';
    
 ELSIF v_sproduc IN (80003, 80002) AND v_activi IN (1,2) THEN  
         
        v_clau_r := pac_isqlfor_conf.f_tex_clausulado (psseguro);
      RETURN v_texto_aux || 'EL PRESENTE CONTRATO SE RIGE POR LAS CONDICIONES GENERALES Y PARTICULARES INCLUIDAS EN LA FORMA ' || v_clau_r || ' ADJUNTA.';

    ELSIF v_sproduc IN (80007, 80008) AND v_activi IN (0) THEN  
           
      RETURN v_texto_aux;
         
  ELSE
        
      v_clau_t := pac_isqlfor_conf.f_tex_clausulado (psseguro);
   
      RETURN v_texto_aux || 'EL PRESENTE CONTRATO SE RIGE POR LAS CONDICIONES GENERALES Y PARTICULARES INCLUIDAS EN LA FORMA ' || v_clau_t || ' ADJUNTA.';
       
END IF; 
--I.R.D IAXIS-5426
 RETURN v_texto;

    END f_texto_clausula;

  /*************************************************************************
    FUNCTION f_texto_formato
    Funcion que retorna texto de caratula

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/     
    FUNCTION f_texto_formato ( 
        psseguro   IN NUMBER ) 
    RETURN VARCHAR2 IS
    v_texto   VARCHAR2(20000);
    v_activi       NUMBER;
    BEGIN
        BEGIN
          SELECT S.CACTIVI
             INTO v_activi
            FROM SEGUROS S
             WHERE s.sseguro = psseguro;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN 
            v_activi := 4;
        END;

        IF v_activi IS NOT NULL THEN         
            SELECT formato 
               INTO v_texto
             FROM formato_planilla 
             WHERE sproduc = (SELECT S.SPRODUC
                        FROM SEGUROS S
                        WHERE S.SSEGURO = psseguro)
                AND cactivi = v_activi;
        END IF; 
    RETURN v_texto;
    END f_texto_formato;

-- Ini IAXIS-2136 - ACL - 03/04/2019
  /*************************************************************************
    FUNCTION f_nombre_beneficiario
    Funcion que retorna el nombre del beneficiario

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/     
    FUNCTION f_nombre_beneficiario ( 
        psseguro   IN NUMBER ) 
    RETURN VARCHAR2 IS
    v_benef         VARCHAR2(300);
    v_sperson       NUMBER;
    v_cdomici       NUMBER;
    v_talias        VARCHAR2(200);
    v_sproduc      NUMBER;
    
    BEGIN
            IF psseguro IS NULL THEN
                 RETURN NULL;   
            ELSE
                select sproduc into v_sproduc from seguros a where a.sseguro = psseguro;
                               
                if NVL(f_parproductos_v(v_sproduc, 'BENIDENT_RIES'), 0) = 0 then 
                    select a.sperson,a.cdomici into v_sperson, v_cdomici from asegurados a where a.sseguro = psseguro and norden = 1;
                else
                    v_sperson := f_parproductos_v(v_sproduc, 'BENIDENT_RIES');
                end if;               
                
                BEGIN
                    SELECT TALIAS INTO v_talias FROM per_direcciones d WHERE d.sperson = v_sperson AND d.cdomici = NVL(v_cdomici,1);
                EXCEPTION 
                    WHEN NO_DATA_FOUND THEN 
                    v_talias := NULL;
                END;
        
                IF v_talias IS NULL THEN
                    v_benef := pac_isqlfor.f_dades_persona(v_sperson,4,8)||' ' || pac_isqlfor.f_dades_persona(v_sperson,5,8);
                ELSE
                    v_benef := v_talias;
                END IF;
            END IF;
        RETURN v_benef;
    END f_nombre_beneficiario;

    /*************************************************************************
    FUNCTION f_ident_beneficiario
    Funcion que retorna el numero de identificacion del beneficiario

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  

    FUNCTION f_ident_beneficiario (psseguro   IN NUMBER ) RETURN VARCHAR2 IS
        v_identbenef    VARCHAR2(20);
        v_sperson       NUMBER;
        v_sproduc      NUMBER;
    
    BEGIN
            IF psseguro IS NULL THEN
                 RETURN NULL;   
            ELSE
                
                select sproduc into v_sproduc from seguros a where a.sseguro = psseguro;
                       
                if NVL(f_parproductos_v(v_sproduc, 'BENIDENT_RIES'), 0) = 0 then 
                    select a.sperson into v_sperson from asegurados a where a.sseguro = psseguro and norden = 1;
                else
                    v_sperson := f_parproductos_v(v_sproduc, 'BENIDENT_RIES');
                end if;
        
                v_identbenef := pac_isqlfor_conf.f_documento_nit(v_sperson);
                
            END IF;
        RETURN v_identbenef;
    END f_ident_beneficiario;

 /*************************************************************************
    FUNCTION f_dv_beneficiario
    Funcion que retorna el digito de verificacion de la identificacion del beneficiario

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  

    FUNCTION f_dv_beneficiario ( 
        psseguro   IN NUMBER ) 
    RETURN NUMBER IS
    v_dvbenef       NUMBER;
    v_sperson       NUMBER;
    v_sproduc      NUMBER;

    BEGIN
            IF psseguro IS NULL THEN
                 RETURN NULL;   
            ELSE
                select sproduc into v_sproduc from seguros a where a.sseguro = psseguro;
               
                if NVL(f_parproductos_v(v_sproduc, 'BENIDENT_RIES'), 0) = 0 then 
                    select a.sperson into v_sperson from asegurados a where a.sseguro = psseguro and norden = 1;
                else
                    v_sperson := f_parproductos_v(v_sproduc, 'BENIDENT_RIES');
                end if;
                
                v_dvbenef := pac_isqlfor_conf.f_dig_verif_nit(v_sperson);
                
            END IF;
        RETURN v_dvbenef;
    END f_dv_beneficiario;     

    /*************************************************************************
    FUNCTION f_dir_beneficiario
    Funcion que retorna la direccion del beneficiario

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  

   FUNCTION f_dir_beneficiario ( 
        psseguro   IN NUMBER) 
    RETURN VARCHAR2 IS
    v_dirbenef      VARCHAR2 (200);
    v_sperson       NUMBER;
    v_cdomici       NUMBER;
    v_sproduc      NUMBER;

    BEGIN  
            IF psseguro IS NULL THEN
                 RETURN NULL;   
            ELSE
                select sproduc into v_sproduc from seguros a where a.sseguro = psseguro;
               
                if NVL(f_parproductos_v(v_sproduc, 'BENIDENT_RIES'), 0) = 0 then 
                    select a.sperson,a.cdomici into v_sperson, v_cdomici from asegurados a where a.sseguro = psseguro and norden = 1;
                else
                    v_sperson := f_parproductos_v(v_sproduc, 'BENIDENT_RIES');
                end if;

                v_dirbenef := pac_isqlfor.f_direccion(v_sperson, nvl(v_cdomici, 1), 'POL');

            END IF;
        RETURN v_dirbenef;
    END f_dir_beneficiario;


   /*************************************************************************
    FUNCTION f_ciudad_benef
    Funcion que retorna la ciudad del beneficiario

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  

   FUNCTION f_ciudad_benef ( 
        psseguro   IN NUMBER) 
    RETURN VARCHAR2 IS
    v_poblac        VARCHAR2 (100);
    v_sperson       NUMBER;
    v_cdomici       NUMBER;
    v_sproduc      NUMBER;

    BEGIN
            IF psseguro IS NULL THEN
                 RETURN NULL;   
            ELSE
                
                select sproduc into v_sproduc from seguros a where a.sseguro = psseguro;
               
                if NVL(f_parproductos_v(v_sproduc, 'BENIDENT_RIES'), 0) = 0 then 
                    select a.sperson,a.cdomici into v_sperson, v_cdomici from asegurados a where a.sseguro = psseguro and norden = 1;
                else
                    v_sperson := f_parproductos_v(v_sproduc, 'BENIDENT_RIES');
                end if;
                
                SELECT tpoblac into v_poblac FROM per_direcciones d, poblaciones p WHERE d.sperson = v_sperson AND d.cdomici = nvl(v_cdomici, 1) AND d.cprovin = p.cprovin AND d.cpoblac = p.cpoblac;
            END IF;
        RETURN v_poblac;
    END f_ciudad_benef;


   /*************************************************************************
    FUNCTION f_tel_beneficiario
    Funcion que retorna el telefono del beneficiario

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  

   FUNCTION f_tel_beneficiario ( 
        psseguro   IN NUMBER) 
    RETURN VARCHAR2 IS
    v_telbenef      VARCHAR2 (20);
    v_sperson       NUMBER;
    v_sproduc      NUMBER;

    BEGIN
    IF psseguro IS NULL THEN
         RETURN NULL;   
    ELSE
    
        select sproduc into v_sproduc from seguros a where a.sseguro = psseguro;
       
        if NVL(f_parproductos_v(v_sproduc, 'BENIDENT_RIES'), 0) = 0 then 
            select a.sperson into v_sperson from asegurados a where a.sseguro = psseguro and norden = 1;
        else
            v_sperson := f_parproductos_v(v_sproduc, 'BENIDENT_RIES');
        end if;

        v_telbenef := pac_isqlfor.f_per_contactos(v_sperson,1);

    END IF;
    RETURN v_telbenef;
    END f_tel_beneficiario;
-- Fin IAXIS-2136 - ACL - 03/04/2019

-- Ini IAXIS-2136 - ACL - 05/04/2019
    /*************************************************************************
    FUNCTION f_datos_abogado
    Funcion que retorna los datos del abogado para el producto caucion judicial 

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  

   FUNCTION f_datos_abogado ( 
        psseguro   IN NUMBER) 
    RETURN VARCHAR2 IS
    v_sproduc      NUMBER;
    v_abogado      VARCHAR2 (200);

    BEGIN
    IF psseguro IS NULL THEN
         RETURN NULL;   
    ELSE
        BEGIN
            select s.sproduc
            into v_sproduc
            from seguros s
            where s.sseguro = psseguro;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            v_sproduc := NULL;
        END;
        IF v_sproduc IN (80007, 80008) THEN
          select ps.trespue
          into v_abogado
            from pregunseg ps, seguros s
            where ps.sseguro = s.sseguro
            and ps.cpregun = 5880
            and s.sproduc = v_sproduc
            and s.sseguro = psseguro
            and ps.nmovimi = (select max(p.nmovimi) from pregunseg p where p.sseguro = psseguro);
        END IF;
    END IF;
    RETURN  v_abogado; 
    END f_datos_abogado;

    /*************************************************************************
    FUNCTION f_datos_juzgado
    Funcion que retorna los datos del abogado para el producto caucion judicial 

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  

   FUNCTION f_datos_juzgado ( 
        psseguro   IN NUMBER) 
    RETURN VARCHAR2 IS
    v_sproduc      NUMBER;
    v_juzgado      VARCHAR2 (200);

    BEGIN
    IF psseguro IS NULL THEN
         RETURN NULL;   
    ELSE
        BEGIN
            select s.sproduc
            into v_sproduc
            from seguros s
            where s.sseguro = psseguro;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            v_sproduc := NULL;
        END;                 
        IF v_sproduc in (80007, 80008) THEN           
         select ps.trespue
          into v_juzgado
            from pregunseg ps, seguros s
            where ps.sseguro = s.sseguro
            and ps.cpregun = 5879
            and s.sproduc = v_sproduc
            and s.sseguro = psseguro
            and ps.nmovimi = (select max(p.nmovimi) from pregunseg p where p.sseguro = psseguro);
        END IF;
    END IF;
    RETURN  v_juzgado; 
    END f_datos_juzgado;

    /*************************************************************************
    FUNCTION f_datos_art_cj
    Funcion que retorna los datos del artculo para el producto caucion judicial 

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  
   FUNCTION f_datos_art_cj ( 
        psseguro   IN NUMBER) 
    RETURN VARCHAR2 IS
    v_sproduc    NUMBER;
    v_tclatit    VARCHAR2 (100);

    BEGIN
    IF psseguro IS NULL THEN
         RETURN NULL;   
    ELSE
        BEGIN
            select s.sproduc
            into v_sproduc
            from seguros s
            where s.sseguro = psseguro;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            v_sproduc := NULL;
        END; 

        IF v_sproduc in (80007, 80008) THEN           
            select cg.tclatit
            into v_tclatit
            from clausupreg cpg, clausupro cpd, clausugen cg
            where cpg.sclapro = cpd.sclapro
            and cg.sclagen = cpd.sclagen
            and cg.cidioma = 8
            and cpg.crespue = (select ps.crespue
                        from pregunseg ps
                        where ps.sseguro = psseguro
                        and ps.cpregun = 5882
                        and ps.nmovimi = (select max(p.nmovimi) from pregunseg p where p.sseguro = psseguro));        
        END IF;   
    END IF;
    RETURN  v_tclatit; 
    END f_datos_art_cj;
-- Fin IAXIS-2136 - ACL - 05/04/2019

-- Ini IAXIS-2136 - ACL - 06/05/2019
   /*************************************************************************
    FUNCTION f_tex_clausulado
    Funcion que retorna TRM caratula de poliza

    param IN psseguro  : identificador unico
    param IN pnmovimi  : numero de movimiento
    return             : Valor establecido
   *************************************************************************/ 
   FUNCTION f_tex_clausulado(
      p_sseguro IN NUMBER)
      RETURN VARCHAR2 IS 
      v_ret      NUMBER;
      v_clasula  VARCHAR2 (50);
      v_cactivi   NUMBER;
      v_sproduc  NUMBER;
      v_crespue  NUMBER;

   BEGIN 
    SELECT S.CACTIVI, S.SPRODUC
         INTO v_cactivi, v_sproduc
        FROM SEGUROS S
         WHERE s.sseguro = p_sseguro;
         
    -- IAXIS-5268 - IRDR - 17/10/2019 -  
    IF v_sproduc in (80001, 80002,80003, 80005, 80012, 80006, 80004) THEN


      select crespue
      INTO v_crespue
        from pregunpolseg
        where sseguro = p_sseguro
        and cpregun IN (2876)
        and nmovimi = 1;
        IF v_cactivi = 2 THEN
            IF v_crespue = 22 THEN
               select p.CCODPLAN
                  into v_clasula
                  from PROD_PLANT_CAB p
                  where p.TCOPIAS = 'pac_impresion_conf.f_clausulado_ecop'
                  and p.sproduc = v_sproduc
                  and p.ctipo = 0;
            END IF;

        ELSIF v_cactivi = 1 THEN
            IF v_crespue = 21 THEN
                select p.CCODPLAN
                into v_clasula
                from PROD_PLANT_CAB p
                where p.TCOPIAS = 'pac_impresion_conf.f_clausulado_part_zf'
                and p.sproduc = v_sproduc
                and p.ctipo = 0;
            ELSIF v_crespue = 19 THEN
               select p.CCODPLAN
                into v_clasula
                from PROD_PLANT_CAB p
                where p.TCOPIAS = 'pac_impresion_conf.f_clausulado_part_p'
                and p.sproduc = v_sproduc
                and p.ctipo = 0;
            ELSIF v_crespue = 20 THEN
               select p.CCODPLAN
                into v_clasula
                from PROD_PLANT_CAB p
                where p.TCOPIAS = 'pac_impresion_conf.f_clausulado_part_brep'
                and p.sproduc = v_sproduc
                and p.ctipo = 0;
            ELSIF v_crespue = 3 THEN
               select p.CCODPLAN
                into v_clasula
                from PROD_PLANT_CAB p
                where p.TCOPIAS = 'pac_impresion_conf.f_clausula_ecopetrol_gb'
                and p.sproduc = v_sproduc
                and p.ctipo = 0;
            END IF; 

        ELSIF v_cactivi = 0 THEN
            IF v_crespue = 5 THEN
              select p.CCODPLAN
              into v_clasula
              from PROD_PLANT_CAB p
              where p.TCOPIAS = 'pac_impresion_conf.f_clausulado_gu_dec1082'
              and p.sproduc = v_sproduc
              and p.ctipo = 0; 
            ELSIF v_crespue = 4 THEN
               select p.CCODPLAN
                into v_clasula
                from PROD_PLANT_CAB p
                where p.TCOPIAS = 'pac_impresion_conf.f_clausulado_gu_rpc'
                and p.sproduc = v_sproduc
                and p.ctipo = 0;
           ELSIF v_crespue = 24 THEN
                select p.CCODPLAN
                    into v_clasula
                    from PROD_PLANT_CAB p
                    where p.TCOPIAS = 'pac_impresion_conf.f_clausulado_gu_ani'
                    and p.sproduc = v_sproduc
                    and p.ctipo = 0;             
          ELSIF v_crespue IN (19, 3, 0) THEN        
               select p.CCODPLAN
                into v_clasula
                from PROD_PLANT_CAB p
                where p.TCOPIAS = 'pac_impresion_conf.f_clausulado_part_p'
                and p.sproduc = v_sproduc
                and p.ctipo = 0;
           END IF; 

        ELSIF v_cactivi = 3 THEN
            IF v_crespue = 23 THEN
              select p.CCODPLAN
                into v_clasula
                from PROD_PLANT_CAB p
                where p.TCOPIAS = 'pac_impresion_conf.f_clausulado_sp'
                and p.sproduc = v_sproduc
                and p.ctipo = 0;
            END IF; 
        END IF;
    ELSIF v_sproduc = 80011 THEN
        v_clasula := 'SU-OD-03-04';
    ELSIF v_sproduc = 8063 THEN
        v_clasula := 'SU-OD-11-03';
    ELSIF v_sproduc = 8062 THEN
        v_clasula := 'SU-OD-09-02';  
    ELSIF v_sproduc IN (80009, 80010) THEN
        v_clasula := 'SU-OD-08-04';
    ELSIF v_sproduc IN (80044) THEN
        v_clasula := 'SU-OD-04-04';
 
  
   ELSE
   
    IF v_sproduc in (80038, 80039, 80040, 80041, 80042, 80043) AND  v_cactivi = 0 THEN
                  
            select crespue
             INTO v_crespue
            from pregunpolseg
            where sseguro = p_sseguro
            and cpregun = 2876
            and nmovimi = 1;
                  
            IF v_crespue = 24 THEN
               v_clasula := 'SU-OD-51-01';
            END IF; 
      
            IF v_crespue in(3,4,5) THEN
               v_clasula := 'SU-OD-04-04';
            END IF;
    
    
      ELSIF v_sproduc IN (80038, 80039, 80040, 80041, 80042, 80043) AND  v_cactivi = 1 THEN
    
            select crespue
             INTO v_crespue
            from pregunpolseg
            where sseguro = p_sseguro
            and cpregun = 2876
            and nmovimi = 1;
                  
            IF v_crespue = 19 THEN
                   v_clasula := 'SU-OD-04-04';
            END IF; 
         
      ELSIF v_sproduc IN (80044) AND  v_cactivi IN (2, 3) THEN
    
            select crespue
             INTO v_crespue
            from pregunpolseg
            where sseguro = p_sseguro
            and cpregun = 2876
            and nmovimi = 1;
                  
            IF v_crespue IN (22, 23) THEN
                   v_clasula := 'SU-OD-04-04';
            END IF;    
            
   
    END IF;
END IF;
    RETURN v_clasula;
   END f_tex_clausulado;

   /*************************************************************************
    FUNCTION f_texto_exclusion
    Funcion que retorna texto de exclusion en una caratula

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/ 
    FUNCTION f_texto_exclusion ( 
        psseguro   IN NUMBER ) 
    RETURN VARCHAR2 IS
    v_texto_excl   VARCHAR2(4000);  --IAXIS-4196 aPfeiffer 
    v_activi       NUMBER;
    v_activi_tex   NUMBER;
    v_sproduc      NUMBER;
    BEGIN
        SELECT S.CACTIVI, S.SPRODUC
         INTO v_activi, v_sproduc
        FROM SEGUROS S
         WHERE s.sseguro = psseguro;

        IF v_activi IS NULL THEN
          v_activi_tex := 0;
        ELSE 
          v_activi_tex := v_activi;
         END IF; 
     
-- IAXIS-5268 - IRDR - 12/09/2019 - Se elimino 2 v_sproduc    
    IF v_sproduc IN (80008) THEN  -- Se ajusta excluyendo los productos disposicion legal
        --IAXIS-4196 aPfeiffer
        SELECT TCLATEX
        INTO v_texto_excl
        FROM CLAUSUGEN
        WHERE SCLAGEN = 4438
        AND CIDIOMA = 8;
        --IAXIS-4196 aPfeiffer
        
        RETURN v_texto_excl;
    ELSE
    
    -- IAXIS-5268 - IRDR - 23/09/2019 - Se agrego and v_sproduc
     IF v_activi <> 0 and v_sproduc not in (80001, 80005, 80038, 80006, 80002, 80012, 80003, 80039) THEN
        --IAXIS-4196 aPfeiffer
        SELECT TCLATEX
        INTO v_texto_excl
        FROM CLAUSUGEN
        WHERE SCLAGEN = 4438
        AND CIDIOMA = 8;
        --IAXIS-4196 aPfeiffer
        
         RETURN v_texto_excl;
     ELSE
        RETURN NULL;
     END IF;
    END IF;
  END f_texto_exclusion;
 -- Fin IAXIS-2136 - ACL - 06/05/2019

 -- Ini IAXIS-2136 - ACL - 09/05/2019
   /*************************************************************************
    FUNCTION f_valor_iva_pesos
    Funcion que retorna TRM caratula de poliza

    param IN psseguro  : identificador unico
    param IN pnmovimi  : numero de movimiento
    return             : Valor establecido
   *************************************************************************/     
    FUNCTION f_valor_iva_pesos(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER)
      RETURN NUMBER IS 
      v_trm     NUMBER;
      v_gastos  NUMBER;
      v_iva   NUMBER;

   BEGIN
    IF p_sseguro IS NULL THEN
         RETURN NULL;   
    ELSE
        v_trm := f_trm_caratula (p_sseguro, p_nmovimi);
        SELECT t.PTIPIVA 
        into v_iva
        FROM TIPOIVA t
            where t.ctipiva = 1;

       IF v_trm IS NOT NULL THEN
        SELECT ((sum(vd.iprinet*DECODE(r.ctiprec, 9, -1, 13, 0, 15, 0, 1))* v_trm) + sum(vd.iderreg*DECODE(r.ctiprec, 9, -1, 13, 0, 15, 0, 1))) * (v_iva/100)
        INTO v_gastos
        FROM recibos r, vdetrecibos vd
        WHERE r.sseguro = p_sseguro
        AND r.nmovimi = p_nmovimi
        AND r.nrecibo = vd.nrecibo;
      ELSE v_gastos := 0;
      END IF;
    END IF;
    RETURN v_gastos;
    END f_valor_iva_pesos;
-- Fin IAXIS-2136 - ACL - 09/05/2019

-- Ini IAXIS-3656 - ACL - 10/05/2019
  /*************************************************************************
    FUNCTION f_tip_movim
    Funcion que retorna la abreviatura del tipo de movimiento

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/ 
    FUNCTION f_tip_movim ( 
        psseguro   IN NUMBER,
        pnmovimi   IN NUMBER) 
    RETURN VARCHAR2 IS
    v_cmotmov    NUMBER; 
    v_tipmov     VARCHAR2(2);

    BEGIN
        SELECT m.cmotmov
         INTO v_cmotmov
        FROM movseguro m
         WHERE m.sseguro = psseguro
         and m.nmovimi = pnmovimi;

        IF v_cmotmov = 100 THEN
            v_tipmov := 'N';
        ELSIF v_cmotmov IN (236, 324, 932, 933, 512, 301, 303, 502, 302, 503, 241, 242, 505, 306, 210, 664, 307, 310, 312, 224, 314, 509, 275, 811, 
                            320, 259, 221, 322, 683, 516, 333, 514, 405, 321, 228, 511, 315, 507, 508, 336, 337, 338, 339, 397, 345, 346) THEN
            v_tipmov := 'A';
        ELSE 
            v_tipmov := 'M';
        END IF;
    RETURN v_tipmov;
  END f_tip_movim;

    /*************************************************************************
    FUNCTION f_delega
    Funcion que retorna si esusuario interno o externo

    param IN psseguro  : identificador unico
    param IN pnmovimi  : numero de movimiento
    return             : Valor establecido
   *************************************************************************/      
   FUNCTION f_delega ( 
        psseguro   IN NUMBER) 
    RETURN VARCHAR2 IS
    v_delega  NUMBER; 
    v_ret     VARCHAR2(2);

    BEGIN
    select u.cdelega 
    into v_delega
        from usuarios u where u.cusuari= (select cusualt from hisestadoseg h where h.sseguro = psseguro
             and h.norden = (select max(h1.norden) from hisestadoseg h1 where sseguro = psseguro));

    IF v_delega = 19000 THEN
        v_ret := NULL;
    ELSE 
       v_ret := 'X';
    END IF;

    RETURN v_ret;  
   END f_delega;
-- Fin IAXIS-3656 - ACL - 10/05/2019

 -- INI IAXIS-3750 - RABQ

   FUNCTION f_distrib_cum_rea(psperson IN VARCHAR2, pparam IN NUMBER) RETURN NUMBER IS
   VVALOR NUMBER := 0;

   BEGIN

        SELECT SUM(DECODE(CES.CTRAMO, pparam, NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(MON.CMONINT,'COP', TO_DATE(TO_CHAR(F_SYSDATE,'dd/mm/yyyy'),'dd/mm/yyyy'), DCE.ICAPCES)), 0), 0)) 
        INTO VVALOR
        FROM DET_CESIONESREA DCE,
             CESIONESREA CES,
             SEGUROS SEG,
             MONEDAS MON,
             TOMADORES TOM,
             GARANSEG GAR2
        WHERE TOM.SPERSON = psperson
            AND GAR2.SSEGURO = DCE.SSEGURO
            AND GAR2.CGARANT = DCE.CGARANT
            AND TO_DATE(TO_CHAR(F_SYSDATE,'dd/mm/yyyy'),'dd/mm/yyyy') <= GAR2.FFINVIG
            AND GAR2.NMOVIMI =
                (SELECT MAX(NMOVIMI)
                 FROM GARANSEG GAR3
                 WHERE GAR2.SSEGURO = GAR3.SSEGURO)
            AND TOM.SSEGURO = CES.SSEGURO
            AND CES.FVENCIM > TO_DATE(TO_CHAR(F_SYSDATE,'dd/mm/yyyy'),'dd/mm/yyyy') AND(CES.FANULAC > TO_DATE(TO_CHAR(F_SYSDATE,'dd/mm/yyyy'),'dd/mm/yyyy')
                      OR CES.FANULAC IS NULL) AND(CES.FREGULA > TO_DATE(TO_CHAR(F_SYSDATE,'dd/mm/yyyy'),'dd/mm/yyyy')
                            OR CES.FREGULA IS NULL)
            AND CES.CGENERA IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
            AND DCE.SSEGURO = SEG.SSEGURO
            AND DCE.SCESREA = CES.SCESREA
            AND NVL(DCE.CDEPURA,'N') = 'N'
            AND MON.CIDIOMA = 8
            AND MON.CMONEDA = PAC_MONEDAS.F_MONEDA_PRODUCTO(SEG.SPRODUC);

        RETURN VVALOR;

    END f_distrib_cum_rea;


  -- FIN IAXIS-3750 - RABQ

-- Ini IAXIS-2136 - ACL - 14/05/2019
    /*************************************************************************
    FUNCTION f_agente_new
    Funcion que retorna la sucursal

    param IN pcagente  : identificador unico
    param IN pctipage  : tipo de agente
    return             : Valor establecido
   *************************************************************************/     
    FUNCTION f_agente_new(pcagente IN NUMBER, pctipage IN NUMBER)
      RETURN VARCHAR IS
      v_cagente   NUMBER;
      v_cpadre    NUMBER;
      v_ret       VARCHAR2(100);  
   BEGIN
      IF pcagente IS NOT NULL THEN
          select rc.cagente, rc.cpadre
            into v_cagente, v_cpadre
         from redcomercial rc where rc.cagente = pcagente;
      END IF;

        IF pctipage = 2 THEN
            v_ret := pac_isqlfor.f_agente(v_cagente);
        ELSE 
            v_ret := pac_isqlfor.f_agente(v_cpadre);
        END IF;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_agente_new;
-- Fin IAXIS-2136 - ACL - 14/05/2019


-- inicio IAXIS-4207 - ACL - 04/06/2019 guilherme
FUNCTION F_AGENTE_BLOCK (pcagente in number)
return NUMBER
IS
    v_permisso_agente number :=0;
    v_permisso_persona number :=0;

    CURSOR cur_agentes IS
    select  a.cactivo AS permiso, a.cagente AS agente from agentes a where 
    sperson = (select sperson from agentes where cagente = pcagente);

BEGIN

    FOR reg IN cur_agentes LOOP -- 1 3 4 6 7

        IF reg.permiso in (0,3,4,7) then
            v_permisso_persona := v_permisso_persona +1;
        ELSIF reg.permiso = 2 and reg.agente = pcagente  THEN
            v_permisso_agente := v_permisso_agente +1;
        END IF;

    END LOOP;

    IF v_permisso_persona > 0 then  
        RETURN 1;
    ELSIF v_permisso_agente > 0 THEN
        RETURN 2;
    END IF;

    return 0;

END F_AGENTE_BLOCK;
-- Fin IAXIS-4207 - ACL - 04/06/2019 guilherme


/*************************************************************************
      FUNCTION f_get_reservatramita
      param in p_nsinies    : numero de siniestro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 sirve  para retornar ya sea Importe Coste, Importe reservas, Imp.pago, Imp. Recobro
   *************************************************************************/
   FUNCTION f_get_reservatramita(
      p_nsinies IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER) 
      RETURN VARCHAR2  IS

    CURSOR c_tramireserva IS
        SELECT  MAX(nmovres) nmovres, idres FROM sin_tramita_reserva  where nsinies = p_nsinies GROUP BY idres;

    vsuma NUMBER := 0;
    vaux NUMBER := 0;
    vreturn VARCHAR2(2000);
    BEGIN

       IF p_tipo = 1 THEN
          FOR var IN c_tramireserva LOOP
          vaux :=0;
          SELECT ireserva INTO vaux FROM sin_tramita_reserva WHERE nsinies = p_nsinies AND idres= var.idres AND nmovres = var.nmovres;
                   vsuma := vsuma + vaux  ;
          END LOOP;
           vreturn := nvl(TO_CHAR(vsuma, 'FM999G999G999G999G990D90'), 0) ; 

       ELSIF p_tipo = 2 THEN
          FOR var IN c_tramireserva LOOP
          vaux :=0;
          SELECT ipago INTO vaux FROM sin_tramita_reserva WHERE nsinies = p_nsinies AND idres= var.idres AND nmovres = var.nmovres;
                   vsuma := vsuma + vaux  ;
          END LOOP;
           vreturn := nvl(TO_CHAR(vsuma, 'FM999G999G999G999G990D90'), 0) ; 

       ELSIF p_tipo = 3 THEN
          FOR var IN c_tramireserva LOOP
          vaux :=0;
          SELECT irecobro INTO vaux FROM sin_tramita_reserva WHERE nsinies = p_nsinies AND idres= var.idres AND nmovres = var.nmovres;
                   vsuma := vsuma + vaux  ;
          END LOOP;
           vreturn := nvl(TO_CHAR(vsuma, 'FM999G999G999G999G990D90'), 0) ;   

       ELSIF p_tipo = 4 THEN
          FOR var IN c_tramireserva LOOP
          SELECT cmonres INTO vreturn FROM sin_tramita_reserva WHERE nsinies = p_nsinies AND idres= var.idres AND nmovres = var.nmovres;      
          END LOOP;

       END IF;

        RETURN vreturn;
    EXCEPTION
        WHEN OTHERS THEN

                   RETURN NULL;
    END f_get_reservatramita;
   --bug 4167  - 11/06/2019


    /*************************************************************************
      FUNCTION f_get_maximapp
      param in p_nsinies    : numero de siniestro
      param in P_TIPO    : 1 sirve  para retornar ya sea la maxima perdida probable, la contingencia o el riesgo
   *************************************************************************/
   FUNCTION f_get_maximapp(
      p_nsinies IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2 IS

    CURSOR c_mpp IS
        SELECT nvl(TO_CHAR(nmaxpp, 'FM999G999G999G999G990D90'), 0)nmaxpp,
        ff_desvalorfijo(8002018,pac_md_common.f_get_cxtidioma,ncontin) ncontin,
        ff_desvalorfijo(8002019,pac_md_common.f_get_cxtidioma,nriesgo) nriesgo
        FROM SIN_TRAMITA_ESTSINIESTRO  WHERE NSINIES=p_nsinies AND NMOVIMI = 
    (SELECT MAX(NMOVIMI)FROM SIN_TRAMITA_ESTSINIESTRO WHERE NSINIES=p_nsinies);

    vicapital NUMBER := 0;
    vreturn VARCHAR2(2000);
  BEGIN

   IF p_tipo = 1 THEN
      FOR var IN c_mpp LOOP
               vreturn := var.nmaxpp;
      END LOOP;
   ELSIF p_tipo = 2 THEN
      FOR var IN c_mpp LOOP
               vreturn := nvl(var.ncontin,' ');
      END LOOP;
   ELSIF p_tipo = 3 THEN
      FOR var IN c_mpp LOOP
               vreturn := nvl(var.nriesgo,' ');
      END LOOP;
   END IF;

    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN
                 RETURN NULL;
  END f_get_maximapp;
   --bug 4167  - 06/25/2019

   /*************************************************************************
      FUNCTION f_get_estadocartera
      param in p_nsinies    : numero de siniestro
   *************************************************************************/
   FUNCTION f_get_estadocartera( p_sseguro IN NUMBER)
      RETURN VARCHAR2 IS
      vreturn VARCHAR2(2000);
  BEGIN
  SELECT tatribu INTO vreturn FROM detvalores WHERE cvalor = 1 AND catribu = 
  ( select m.cestrec  FROM recibos r, movrecibo m WHERE  r.sseguro = p_sseguro AND r.nrecibo = m.nrecibo
  AND SMOVREC= (SELECT MAX(SMOVREC) FROM  movrecibo WHERE nrecibo= m.nrecibo) 
  ) 
  AND cidioma = 8;

    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN
                 RETURN NULL;
  END f_get_estadocartera;
    --bug 4167  - 06/25/2019
    
        /*************************************************************************
      FUNCTION f_nom_nit_pagare
      param in p_nsinies    : numero de siniestro
      funcionalidad   : para el reporte de pagare cuando es consorcio nececito tener las personas que conforman junto a su nit 

   *************************************************************************/
   FUNCTION f_nom_nit_pagare(
      pnsinies IN NUMBER)
     RETURN VARCHAR2 IS

  CURSOR c_cursor IS
        SELECT UPPER(DRTP.TNOMBRE || DECODE(DRTP.TNOMBRE, NULL, NULL, ' ')||
        DRTP.TAPELLI1||DECODE(DRTP.TAPELLI1, NULL, NULL, ' ')||DRTP.TAPELLI2 ||DECODE(DRTP.TAPELLI2, NULL, NULL, ' ')) NOMBRE,
        PES.NNUMIDE NIT
        FROM PER_PERSONAS PES, PER_DETPER DRTP, per_personas_rel ppr, tomadores tm
        WHERE DRTP.SPERSON=PES.SPERSON
        AND  ppr.sperson = tm.sperson
        and ppr.cagrupa = tm.cagrupa      
        AND PES.SPERSON =ppr.SPERSON_REL
        and tm.sseguro =(SELECT SSEGURO FROM SIN_SINIESTRO WHERE NSINIES=pnsinies);


        vreturn VARCHAR2(2000);
        vcontador   NUMBER := 0;
        num_total_rows NUMBER;
  BEGIN
    FOR var IN c_cursor LOOP
      num_total_rows := c_cursor%ROWCOUNT;
    END LOOP; 
    
      FOR var IN c_cursor LOOP
      IF  num_total_rows = 1 THEN
           vreturn:=var.NOMBRE||' Nit. No.'|| var.NIT;
     ELSIF num_total_rows > 1  then
             vcontador:=vcontador+1;
             
             IF vcontador = num_total_rows THEN
               vreturn:=vreturn||' Y '|| var.NOMBRE||' Nit. No.'|| var.NIT;
          ELSE
           vcontador:=vcontador+1;
          IF vcontador = num_total_rows THEN
          vreturn:=vreturn|| var.NOMBRE||' Nit. No.'|| var.NIT;
            ELSE
            vreturn:=vreturn|| var.NOMBRE||' Nit. No.'|| var.NIT ||', ';
             END IF;
             vcontador:=vcontador-1;   
          END IF;
          
      END IF;
     END LOOP; 
      
    RETURN vreturn;
  EXCEPTION
      WHEN OTHERS THEN

                 RETURN NULL;
 END f_nom_nit_pagare;
   -- Fin  bug 2485
   
   --tarea 4196 inicio 22/07/2019 André Pfeiffer
   /*************************************************************************
    FUNCTION f_texto_exclusion_rc
    Funcion que retorna texto de exclusion en una caratula R.C.

    param IN psseguro  : identificador unico
    param IN pcampo    : la ordem de lo texto (se es lo primeir o segundo campo)
    return             : Valor establecido
   *************************************************************************/ 
    FUNCTION f_texto_exclusion_rc ( 
        psseguro   IN NUMBER,
        pcampo   IN NUMBER) 
    RETURN VARCHAR2 IS
    v_texto_excl    VARCHAR2(4000); 
    v_ramo        NUMBER;
    -- IAXIS-5268 - IRDR - 12/09/2019 - Se agrega v_activi, v_sproduc   
    v_activi      NUMBER;
    v_sproduc     NUMBER;
    
    BEGIN
        SELECT S.CRAMO, S.SPRODUC, S.CACTIVI
         INTO v_ramo , v_sproduc, v_activi
        FROM SEGUROS S
         WHERE s.sseguro = psseguro;

-- IAXIS-4197 - IRDR - 23/09/2019 - Se agregan v_sproduc 
   IF v_ramo = 802 OR v_sproduc in (80001, 80003, 80002, 80006) and v_activi = 3
                       or v_sproduc in (80011) and v_activi = 0 
                       or v_sproduc in (80007) and v_activi = 0 
                       or v_sproduc not in (80039) and v_activi not in (0,1) then
        IF pcampo = 1 THEN
            SELECT TCLATEX
            INTO v_texto_excl
            FROM CLAUSUGEN
            WHERE SCLAGEN = 4439
            AND CIDIOMA = 8;
        ELSIF pcampo = 2 THEN
            SELECT TCLATEX
            INTO v_texto_excl
            FROM CLAUSUGEN
            WHERE SCLAGEN = 4440
            AND CIDIOMA = 8;
        END IF;
        
        RETURN v_texto_excl;
     ELSE
        RETURN ' ';     
     END IF;
  END f_texto_exclusion_rc;
    --tarea 4196 FIN 22/07/2019 André Pfeiffer 
	
	/*************************************************************************
    FUNCTION f_texto_clau_caratula
    Funcion que retorna las clausulas de la poliza SEGUN EL TIPO ESPECIFICADO

    param IN psseguro  : identificador unico de la poliza
    param IN pnmovimi  : identificador del movimiento de la poliza
    param IN ptipo     : identificador del tipo de clausula 1.- clausulas definidas, 2.- clausulas especificas
    return             : Concatenacion de las clausulas del tipo indicado
   *************************************************************************/ 
    FUNCTION f_texto_clau_caratula (psseguro IN NUMBER, pnmovimi IN NUMBER, ptipo IN NUMBER) RETURN VARCHAR2 IS
    
    v_texto    VARCHAR2(4000); 

    BEGIN
    
     IF ptipo = 1 then
        
        select LISTAGG(cg.tclatex, CHR(10)) WITHIN GROUP (order by c.sclagen) into v_texto from claususeg c, clausugen cg where c.sseguro = psseguro and c.nmovimi = pnmovimi and c.ffinclau is null and c.SCLAGEN = cg.SCLAGEN and cg.CIDIOMA = 8;
       
     ELSE
     
        select  LISTAGG(ce.tclaesp, CHR(10)) WITHIN GROUP (order by ce.NORDCLA) into v_texto from clausuesp ce where ce.sseguro = psseguro and ce.nmovimi = pnmovimi;
         
     END IF;
     
     RETURN v_texto;
     
  END f_texto_clau_caratula; 
  
    FUNCTION f_get_ultmov( PSSEGURO IN NUMBER, PTIPO IN NUMBER DEFAULT 2) RETURN NUMBER IS
      VRETURN NUMBER;
      BEGIN  
      IF PTIPO = 1 THEN
        SELECT MAX(NMOVIMI) INTO VRETURN FROM MOVSEGURO WHERE SSEGURO = PSSEGURO AND CMOVSEG <> 52;
      ELSE 
         SELECT MAX(NMOVIMI) INTO VRETURN FROM MOVSEGURO WHERE SSEGURO = PSSEGURO;
      END IF;
    
        RETURN vreturn;
      EXCEPTION
          WHEN OTHERS THEN
                     RETURN NULL;
  END f_get_ultmov;
  
  
	
END PAC_ISQLFOR_CONF;
/
