create or replace PACKAGE BODY PAC_LISTVALORES AS
   /******************************************************************************
      NOMBRE:    PAC_LISTVALORES
      PROPOSITO: Funcion que ejecuta dinamicamente la select para obtener la lista de registros
      REVISIONES:
      Ver        Fecha        Autor             Descripcion
      ---------  ----------  ---------------  ------------------------------------
      1.0        ??/??/????   ???               1. Creacion del package.
      2.0        20/01/2011   DRA               2. 0016576: AGA602 - Parametritzacio de reemborsaments per veterinaris
      3.0        07/03/2012   JMB               3. 0020893: MDP - DIR - Modelo de datos de direcciones
      4.0        21/05/2015   CJMR              4. 0035888: Nota 205345 - Realizar la substitucion del upper nnumnif o nnumide
      5.0        28/10/2019   SGM               5. IAXIS-6149: Realizar consulta de personas publicas
   ******************************************************************************/
   FUNCTION f_opencursor(squery IN VARCHAR2)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
   BEGIN
      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_listvalores.F_OpenCursor', NULL,
                     'Error no controlado', SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_opencursor;

   FUNCTION f_get_consulta(
      codigo IN VARCHAR2,
      condicion IN VARCHAR2,
      pcidioma IN NUMBER,
      numerror IN OUT NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vquery         VARCHAR2(2000);
      verr           ob_error;
      j              NUMBER := 1;
      vcondicion     VARCHAR2(200);
      vsperson       VARCHAR2(20);
      vtexto         VARCHAR2(200);
      pos_pipe       NUMBER;
      vprovin        VARCHAR2(10);
      vcp            VARCHAR2(30);
      texto          VARCHAR2(100);
      vdata          DATE;
      vtraza         NUMBER;
      vttiteve       VARCHAR2(500);
      vwhere         VARCHAR2(500);
      vnnumide       VARCHAR2(50);
      -- BUG16576:DRA:20/01/2011:Inici
      vcacto         VARCHAR2(20);
      vtacto         VARCHAR2(200);
      vcgarant       NUMBER;
      vagr_salud     VARCHAR2(20);
      pos_pipe2      NUMBER;
      pos_pipe3      NUMBER;
      vtab           VARCHAR2(30);
      -- BUG16576:DRA:20/01/2011:Fi
      vtmpcondicion  VARCHAR2(1000);
   BEGIN
      vtmpcondicion := REPLACE(condicion, CHR(39), '');

      IF INSTR(vtmpcondicion, '|') = 0 AND codigo NOT IN ('LISTA_POBLACION_GARAN1', 'LISTA_POBLACION_GARAN2', 'LISTA_POBLACION_GARAN3') THEN
         RAISE NO_DATA_FOUND;
      END IF;

      IF codigo = 'LISTA_PAIS' THEN
         IF vtmpcondicion IS NULL
            OR vtmpcondicion = '|' THEN
            cur :=
               f_opencursor
                  ('Select cpais valor, tpais texto, cpais codigo From despaises where cidioma = '
                   || pcidioma || ' ORDER BY tpais');
         ELSE
            cur :=
               f_opencursor
                  ('Select cpais valor, tpais texto, cpais codigo From despaises where cidioma = '
                   || pcidioma || ' and upper(tpais) like ''%'
                   || UPPER(REPLACE(vtmpcondicion, '|', '')) || '%''' || ' ORDER BY tpais');
         END IF;

         IF cur%NOTFOUND THEN
            numerror := 1000356;
            RETURN cur;
         END IF;
      ELSIF codigo = 'LISTA_PROVINCIA' THEN
         IF vtmpcondicion IS NOT NULL
            AND INSTR(vtmpcondicion, '|') > 0 THEN
            vquery := 'select cprovin valor , tprovin texto, cprovin codigo ';
            vquery := vquery || 'from provincias ';
            vquery := vquery || ' where cpais = nvl( substr( ''' || vtmpcondicion
                      || ''', 1, INSTR(''' || vtmpcondicion || ''',''|'',1)  -1) , cpais)';   -- Hasta la primera posicion esta el codigo del pais
            vquery := vquery || '  and (upper ( tprovin) like ''%''||substr( upper('''
                      || vtmpcondicion || '''), INSTR(''' || vtmpcondicion
                      || ''',''|'',1) +1 )||''%''';
            vquery := vquery || ' or ';
            vquery := vquery || '  substr( ''' || vtmpcondicion || ''', INSTR('''
                      || vtmpcondicion || ''',''|'',1) +1 ) is null)';
         ELSE
            vquery := 'select cprovin valor , tprovin texto, cprovin codigo ';
            vquery := vquery || 'from provincias ';
         END IF;

         vquery := vquery || '  order by tprovin';
         cur := f_opencursor(vquery);

         IF cur%NOTFOUND THEN
            numerror := 102551;
            RETURN cur;
         END IF;
      ELSIF codigo = 'LISTA_POBLACION_NOPROV' THEN
         vtmpcondicion := SUBSTR(vtmpcondicion, 1, INSTR(vtmpcondicion, '|') - 1);
         vquery :=
            'select distinct po.cpoblac valor , po.tpoblac texto, po.cpoblac codigo, po.cprovin, c.cpostal'
            || ' from poblaciones po, codpostal c,provincias pr' || ' where pr.cpais = '
            || vtmpcondicion || '  and pr.cprovin = po.cprovin'
            || '  and c.CPOBLAC(+) = po.cpoblac '
            || '  and c.cprovin = po.cprovin ';
         vquery := vquery || '  order by tpoblac';
         cur := f_opencursor(vquery);

         IF cur%NOTFOUND THEN
            numerror := 102330;
            RETURN cur;
         END IF;
      --INI TCS 309 08/03/2019 AP
      ELSIF codigo in ('LISTA_POBLACION_GARAN1', 'LISTA_POBLACION_GARAN2', 'LISTA_POBLACION_GARAN3') THEN
         vquery :=
            'select distinct po.cpoblac valor , po.tpoblac texto, po.cpoblac codigo, po.cprovin, c.cpostal'
            || ' from poblaciones po, codpostal c,provincias pr' || ' where pr.cpais = 170 '
            || '  and pr.cprovin = po.cprovin'
            || '  and c.CPOBLAC(+) = po.cpoblac '
            || '  and c.cprovin = po.cprovin '
            || '  and UPPER(po.tpoblac) like UPPER(''%'|| vtmpcondicion || '%'') or  ''' || vtmpcondicion || ''' is null';
         vquery := vquery || '  order by tpoblac';
         p_control_error ('AP',2,'CONSULTA: ' || 'codigo ' || codigo || ' condicion ' || condicion || ' vtmpcondicion ' || vtmpcondicion);
         cur := f_opencursor(vquery);
         IF cur%NOTFOUND THEN
            numerror := 102330;
            RETURN cur;
         END IF;
      --FIN TCS 309 08/03/2019 AP
      ELSIF codigo = 'LISTA_POBLACION' THEN
         IF vtmpcondicion IS NOT NULL
            AND INSTR(vtmpcondicion, '|') > 0 THEN
            -- Buscamos la provincia
            SELECT SUBSTR(vtmpcondicion, 1, INSTR(vtmpcondicion, '|', 1) - 1)
              INTO vprovin
              FROM DUAL;

            -- Buscamos la descripcion
            SELECT SUBSTR(vtmpcondicion,
                          INSTR(vtmpcondicion, '|', INSTR(vtmpcondicion, '|') + 1) + 1,
                          INSTR(vtmpcondicion, '|', -1)
                          - INSTR(vtmpcondicion, '|', INSTR(vtmpcondicion, '|') + 1) - 1)
              INTO texto
              FROM DUAL;

            -- Buscamos el CP
            SELECT SUBSTR(vtmpcondicion, INSTR(vtmpcondicion, '|') + 1,
                          INSTR(vtmpcondicion, '|', INSTR(vtmpcondicion, '|') + 1)
                          - INSTR(vtmpcondicion, '|') - 1)
              INTO vcp
              FROM DUAL;

            vquery :=
               'select distinct po.cpoblac valor , po.tpoblac texto, po.cpoblac codigo, po.cprovin ';
            vquery := vquery || 'from poblaciones po, codpostal c ';
            vquery := vquery || ' where po.cprovin = nvl(' || vprovin || ', po.cprovin) ';
            vquery := vquery || ' and (upper ( po.tpoblac) like ''%' || UPPER(texto) || '%''';
            vquery := vquery || ' or  ''' || texto || ''' is null)';
            vquery := vquery || ' and c.cprovin(+) = po.cprovin and c.cpoblac(+)= po.cpoblac ';
            vquery := vquery || ' and (c.cpostal = ''' || vcp || ''' or ''' || vcp
                      || ''' is null)';
         ELSE
            vquery := 'select cpoblac valor , tpoblac texto, cpoblac codigo, cprovin ';
            vquery := vquery || 'from poblaciones ';
         END IF;

         vquery := vquery || '  order by tpoblac';
         cur := f_opencursor(vquery);

         IF cur%NOTFOUND THEN
            numerror := 102330;
            RETURN cur;
         END IF;
      ELSIF codigo = 'LISTA_DIR_LOCALIDAD' THEN
         IF vtmpcondicion IS NOT NULL
            AND INSTR(vtmpcondicion, '|') > 0 THEN
            -- Buscamos la provincia
            SELECT SUBSTR(vtmpcondicion, 1, INSTR(vtmpcondicion, '|', 1) - 1)
              INTO vprovin
              FROM DUAL;

            -- Buscamos la descripcion
            SELECT SUBSTR(vtmpcondicion,
                          INSTR(vtmpcondicion, '|', INSTR(vtmpcondicion, '|') + 1) + 1,
                          INSTR(vtmpcondicion, '|', -1)
                          - INSTR(vtmpcondicion, '|', INSTR(vtmpcondicion, '|') + 1) - 1)
              INTO texto
              FROM DUAL;

            -- Buscamos el CP
            SELECT SUBSTR(vtmpcondicion, INSTR(vtmpcondicion, '|') + 1,
                          INSTR(vtmpcondicion, '|', INSTR(vtmpcondicion, '|') + 1)
                          - INSTR(vtmpcondicion, '|') - 1)
              INTO vcp
              FROM DUAL;

            vquery :=
               'select distinct lo.idlocal valor , lo.tlocali texto, lo.idlocal codigo, lo.cprovin cprovin ';
            vquery := vquery || 'from dir_localidades lo, codpostal c ';
            vquery := vquery || ' where lo.cprovin = nvl(' || vprovin || ', lo.cprovin) ';
         ELSE
            vquery := 'select idlocal valor , tlocali texto, idlocal codigo, cpoblac cprovin ';
            vquery := vquery || 'from dir_localidades ';
         END IF;

         vquery := vquery || '  order by tlocali';
         cur := f_opencursor(vquery);

         IF cur%NOTFOUND THEN
            numerror := 102330;
            RETURN cur;
         END IF;
        ELSIF CODIGO = 'DATOSBASICOSPERSONA'
              AND INSTR(VTMPCONDICION, '|') > 0
        THEN
            NUMERROR := F_STRSTD(CONDICION, VCONDICION); -- Quita los acentos
            NUMERROR := F_STRSTD2(VCONDICION, VCONDICION); -- Quita los 2 espacios en blanco
            POS_PIPE := INSTR(VCONDICION, '|');
            VNNUMIDE := SUBSTR(VCONDICION, 1, POS_PIPE - 1);
            VQUERY   := ' SELECT
                       LTRIM(RTRIM(pd.tapelli1)) primer_apellido,
                       LTRIM(RTRIM(pd.tapelli2)) segundo_apellido,
                       LTRIM(RTRIM(pd.tnombre)) nombre,
                       pp.ctipide tipo_documento
                       FROM per_detper pd, per_personas pp
                       WHERE pd.sperson = pp.sperson';

            IF VNNUMIDE IS NOT NULL
            THEN
               VWHERE := ' and nnumide like ' || CHR(39) || vnnumide || CHR(39);
               VQUERY := VQUERY || VWHERE;

               CUR := F_OPENCURSOR(VQUERY);
            END IF;

            IF CUR%NOTFOUND
            THEN
                NUMERROR := 100534;
                RETURN CUR;
            END IF;
      ELSIF codigo = 'DATOSPERSONA'
            AND INSTR(vtmpcondicion, '|') > 0 THEN
         --numerror := f_strstd(vtmpcondicion, vcondicion);   -- Quita los acentos
         numerror := f_strstd(condicion, vcondicion);   -- Quita los acentos
         numerror := f_strstd2(vcondicion, vcondicion);   -- Quita los 2 espacios en blanco
         pos_pipe := INSTR(vcondicion, '|');
         -- Bug 35888/205345 Realizar la substitucion del upper nnumnif o nnumide - CJMR D01 A01
           --vnnumide := UPPER(SUBSTR(vcondicion, 1, pos_pipe - 1));
         vnnumide := SUBSTR(vcondicion, 1, pos_pipe - 1);
         vtexto := UPPER(SUBSTR(vcondicion, pos_pipe + 1));
         vquery :=
            ' SELECT   nnumide valor,
                       LTRIM(RTRIM(tapelli))||DECODE(tnombre, NULL, NULL, '', ''||LTRIM(RTRIM(tnombre)))  texto,
                       sperson codi
                       FROM personas_agente
                       WHERE rownum < 101 ';

         IF vnnumide IS NOT NULL THEN
            -- Bug 35888/205345 Realizar la substitucion del upper nnumnif o nnumide - CJMR D01 A01
            --vwhere := ' and upper(nnumide) like ' || CHR(39) || vnnumide || CHR(39);
            --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                 'NIF_MINUSCULAS'),
                   0) = 1 THEN
               vwhere := ' and UPPER(nnumide) LIKE UPPER(''' || '%' || vnnumide || '%'
                         || ''')';
               vquery := vquery || vwhere;
            ELSE
               vwhere := ' and nnumide like ' || CHR(39) || vnnumide || CHR(39);
               vquery := vquery || vwhere;
            END IF;
         END IF;

         IF vtexto IS NOT NULL THEN
            vwhere := vwhere || ' and UPPER(tbuscar) like ''%' || vtexto || '%''';
            vquery := vquery || vwhere;
         END IF;

         cur := f_opencursor(vquery);

         IF cur%NOTFOUND THEN
            numerror := 100534;
            RETURN cur;
         END IF;
      ELSIF codigo = 'LISTA_REEMBACTOS' THEN
         IF vtmpcondicion IS NOT NULL
            AND INSTR(vtmpcondicion, '|') > 0 THEN
            -- BUG16576:DRA:20/01/2011:Inici
            -- El formato es el siguiente:
            --    CACTO|TACTO|CGARANT|AGR_SALUD
            pos_pipe := INSTR(vtmpcondicion, '|');
            vcacto := UPPER(SUBSTR(vtmpcondicion, 1, pos_pipe - 1));
            vtacto := UPPER(SUBSTR(vtmpcondicion, pos_pipe + 1));
            pos_pipe2 := INSTR(vtacto, '|');

            BEGIN
               vtexto := SUBSTR(vtacto, pos_pipe2 + 1);
               pos_pipe3 := INSTR(vtexto, '|');
               vcgarant := TO_NUMBER(SUBSTR(vtexto, 1, pos_pipe3 - 1));
               vagr_salud := SUBSTR(vtexto, pos_pipe3 + 1);

               IF vcgarant IS NOT NULL THEN
                  vtab := ', actos_garanpro g';
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  vcgarant := NULL;
                  vagr_salud := NULL;
                  vtab := NULL;
            END;

            IF pos_pipe2 > 0 THEN
               vtacto := SUBSTR(vtacto, 1, pos_pipe2 - 1);
            END IF;

            -- BUG16576:DRA:20/01/2011:Inici
            vquery := 'SELECT c.cacto codigo, c.cacto valor, d.tacto texto';
            vquery := vquery || ' FROM codactos c, desactos d' || vtab;
            vquery := vquery || ' WHERE d.cidioma = ' || pcidioma || ' AND c.cacto = d.cacto ';
            vquery := vquery || ' AND (UPPER(c.cacto) = UPPER(NVL(''' || vcacto
                      || ''', c.cacto)))';
            vquery := vquery || ' AND (UPPER(d.tacto) LIKE ''%' || vtacto || '%''';
            vquery := vquery || ' OR ''' || vtacto || ''' IS NULL)';

            IF vtab IS NOT NULL THEN
               vquery := vquery || ' AND g.cacto = c.cacto';
               vquery := vquery || ' AND g.cgarant = ' || vcgarant;
               vquery := vquery || ' AND (g.agr_salud = ''' || vagr_salud || ''' OR '''
                         || vagr_salud || ''' IS NULL)';
               vquery := vquery || ' AND TRUNC (g.fvigencia) <= TRUNC (f_sysdate)';
               vquery := vquery
                         || ' AND (TRUNC (g.ffinvig) > TRUNC (f_sysdate) OR ffinvig IS NULL)';
               vquery := vquery || ' AND g.cestado = 1';
            END IF;
         ELSE
            vquery := 'SELECT c.cacto codigo, c.cacto valor, d.tacto texto';
            vquery := vquery || ' FROM codactos c, desactos d ';
            vquery := vquery || ' WHERE d.cidioma = ' || pcidioma || ' AND c.cacto = d.cacto ';
         END IF;

         vquery := vquery || ' ORDER BY d.tacto ';
         cur := f_opencursor(vquery);

         IF cur%NOTFOUND THEN
            numerror := 102330;
            RETURN cur;
         END IF;
      ELSIF codigo = 'LISTA_EVENTOS' THEN
         IF vtmpcondicion IS NOT NULL THEN
            pos_pipe := INSTR(vtmpcondicion, '|');
            vtraza := 0;
            vdata := TO_DATE(SUBSTR(vtmpcondicion, 1, pos_pipe - 1), 'dd/mm/yyyy');
            vttiteve := SUBSTR(vtmpcondicion, pos_pipe + 1);
            vtraza := 11;
            vquery := 'select codev.cevento codigo, codev.cevento valor, desev.ttiteve texto ';
            vtraza := 12;
            vquery := vquery || ' from sin_codevento codev, sin_desevento desev ';
            vtraza := 13;
            vquery := vquery || ' where codev.finieve <= ' || CHR(39) || vdata || CHR(39);
            vtraza := 14;
            vquery := vquery || ' AND ( codev.ffineve IS NULL OR  codev.ffineve > ''' || vdata
                      || ''')';
            vquery := vquery || ' AND codev.cevento = desev.cevento AND desev.cidioma = '
                      || pcidioma;
            vtraza := 2;
            vquery := vquery || ' AND UPPER (TTITEVE) like ''%''||upper(''' || vttiteve
                      || ''')||''%''';
         ELSE
            vquery := 'select codev.cevento codigo, codev.cevento valor, desev.ttiteve texto ';
            vquery := vquery || ' from sin_codevento codev, sin_desevento desev ';
            vquery := vquery || ' where codev.cevento = desev.cevento AND desev.cidioma = '
                      || pcidioma;
         END IF;

         vtraza := 3;
         vquery := vquery || '  order by desev.tevento ';
         p_tab_error(f_sysdate, f_user, 'Pac_listvalores.f_get_consulta 5', vtraza,
                     'Error no controlado', vquery);
         vtraza := 4;
         cur := f_opencursor(vquery);
         vtraza := 5;

         IF cur%NOTFOUND THEN
            numerror := 9001070;
            RETURN cur;
         END IF;

         vtraza := 6;
      -- Bug 14284 - 01/05/2010 - AMC
      ELSIF codigo = 'LISTA_GARANTIAS' THEN
         pos_pipe := INSTR(vtmpcondicion, '|');
         vtexto := UPPER(SUBSTR(vtmpcondicion, pos_pipe + 1));

         IF vtexto IS NOT NULL THEN
            vquery :=
               'select cgarant codigo, cgarant valor,tgarant texto from garangen where upper(tgarant) like ''%''||upper('''
               || vtexto || ''')||''%'' and cidioma =' || pcidioma || ' order by cgarant asc';
         ELSE
            vquery :=
               'select cgarant codigo, cgarant valor,tgarant texto from garangen where cidioma = '
               || pcidioma || ' order by cgarant asc';
         END IF;

         cur := f_opencursor(vquery);

         IF cur%NOTFOUND THEN
            numerror := 140999;
            RETURN cur;
         END IF;
      --Fi Bug 14284 - 01/05/2010 - AMC
      ELSE
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_listvalores.f_get_consulta', vtraza,
                     'Error no controlado', SQLERRM);
         /*  Mensajes.EXTEND;
           verr:=ob_error.instanciar(103212,SQLERRM);
           j:=Mensajes.last;
           Mensajes(j):=verr;*/
         RETURN cur;   -- Error no controlado
   END f_get_consulta;
--SGM IAXIS-6149 28/10/2019   
   FUNCTION f_get_publicinfo(
      codigo IN VARCHAR2,
      condicion IN VARCHAR2,
      pcidioma IN NUMBER,
      numerror IN OUT NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vquery         VARCHAR2(2000);
      verr           ob_error;
      j              NUMBER := 1;
      vcondicion     VARCHAR2(200);
      vtexto         VARCHAR2(200);
      pos_pipe       NUMBER;
      vtraza         NUMBER;
      vwhere         VARCHAR2(500);
      vnnumide       VARCHAR2(50);
      vtmpcondicion  VARCHAR2(1000);
   BEGIN
      vtmpcondicion := REPLACE(condicion, CHR(39), '');

      IF INSTR(vtmpcondicion, '|') = 0 AND codigo NOT IN ('LISTA_POBLACION_GARAN1', 'LISTA_POBLACION_GARAN2', 'LISTA_POBLACION_GARAN3') THEN
         RAISE NO_DATA_FOUND;
      END IF;

      IF codigo = 'DATOSPERSONA'
            AND INSTR(vtmpcondicion, '|') > 0 THEN
         numerror := f_strstd(condicion, vcondicion);   -- Quita los acentos
         numerror := f_strstd2(vcondicion, vcondicion);   -- Quita los 2 espacios en blanco
         pos_pipe := INSTR(vcondicion, '|');
         vnnumide := SUBSTR(vcondicion, 1, pos_pipe - 1);
         vtexto := UPPER(SUBSTR(vcondicion, pos_pipe + 1));
         vquery :=
            ' SELECT p.sperson codi, p.cagente, ff_desagente(p.cagente) tagente, LPAD(p.nnumide, 10, '' '') valor, d.tnombre || '' '' || d.tapelli1|| '' '' ||d.tapelli2 texto
	                   FROM per_personas p, per_detper d
                       WHERE d.sperson = p.sperson
                       AND d.fmovimi in ( select max (fmovimi) from per_detper dd where dd.sperson = p.sperson)
                       AND ROWNUM <= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''),100)
                       AND p.swpubli = 1 ';

         IF vnnumide IS NOT NULL THEN
            -- Bug 35888/205345 Realizar la substitucion del upper nnumnif o nnumide - CJMR D01 A01
            --vwhere := ' and upper(nnumide) like ' || CHR(39) || vnnumide || CHR(39);
            --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                 'NIF_MINUSCULAS'),
                   0) = 1 THEN
               vwhere := ' and UPPER(p.nnumide) LIKE UPPER(''' || '%' || vnnumide || '%'
                         || ''')';
               vquery := vquery || vwhere;
            ELSE
               vwhere := ' and p.nnumide like ' || CHR(39) || vnnumide || CHR(39);
               vquery := vquery || vwhere;
            END IF;
         END IF;

         IF vtexto IS NOT NULL THEN
            vwhere := vwhere || ' and UPPER(d.tbuscar) like ''%' || vtexto || '%''';
            vquery := vquery || vwhere;
         END IF;

         cur := f_opencursor(vquery);
         IF cur%NOTFOUND THEN
            numerror := 100534;
            RETURN cur;
         END IF;
      ELSE
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_listvalores.f_get_publicinfo', vtraza,
                     'Error no controlado', SQLERRM);
         /*  Mensajes.EXTEND;
           verr:=ob_error.instanciar(103212,SQLERRM);
           j:=Mensajes.last;
           Mensajes(j):=verr;*/
         RETURN cur;   -- Error no controlado
   END f_get_publicinfo;   
END pac_listvalores;
