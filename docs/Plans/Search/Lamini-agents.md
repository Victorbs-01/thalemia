Lamini, la chica hace cursor en deelearning.ia, pero parece que esto fue adquirido por amd

sobre la empresa lamini, puedes buscar la informacion que existe de ellos, e indicarme lo que hacian, que puedo guardar de ellos, para aplicarlo a mi erp, cuando tenga agentes haciendo cosas en el erp

Genial — investigué lo que encontré sobre la empresa Lamini (sí, me puse mi gorro de investigador nerd) y acá va un resumen + sugerencias de lo que puedes tomar prestado para aplicar en tu ERP con agentes haciendo cosas.

✅ ¿Qué hace Lamini?

Aquí los puntos clave:

Lamini se presenta como una plataforma empresarial para entrenar, afinar (fine-tune) y desplegar modelos de lenguaje grande (LLM = large language model) basados en datos propios de la empresa.
Lamini Docs
+4
Paraform
+4
Rundown AI
+4

Permite despliegues en diferentes modelos: en la nube, on-premises, incluso en entornos aislados (air-gapped).
WorkHub
+1

Una técnica que promocionan se llama «memory tuning» (afinamiento de memoria) — básicamente entrenar el modelo para que recuerde hechos específicos de los datos de la empresa, mejorar precisión y reducir “alucinaciones”.
WorkHub
+2
eesel AI
+2

Su foco es para empresas que tienen datos internos valiosos y quieren construir “agentes” o “modelos” personalizados muy ajustados a esos datos, no tanto en usar un chatbot genérico ya hecho.
eesel AI
+1

Inversión significativa: levantaron US $25 millones en financiación en 2024, lo que indica que tienen respaldo serio.
SiliconANGLE
+1

🛠 ¿Qué puedo “guardar” de Lamini para tu ERP con agentes?

Aquí viene la parte interesante: qué ideas puedes adaptar al diseño de tu ERP cuando incorpores agentes que “hacen cosas”.

Idea de Lamini Cómo aplicarlo en tu ERP con agentes
Fine-tune / personalización con datos propios Los agentes de tu ERP (por ejemplo: atención al cliente, gestión de stock, seguimiento de pedidos) deberían tener acceso a datos de tu sistema (clientes, productos, historial) para comportarse de forma “contextualizada”.
Diferentes modos de despliegue / control sobre infraestructura Aunque tu stack no sea tan complejo como Lamini, define si tus agentes funcionarán en la nube, on-premises o híbrido, y quien tiene el control de datos, seguridad, respaldo.
Memoria / conocimiento específico interno Los agentes pueden tener “módulos de conocimiento” que contienen reglas, hechos del negocio, políticas internas: por ejemplo “esta promoción sólo aplica para tal cliente”, “este producto no se puede vender a menor precio”, etc.
Validación / precisión / evitar “alucinaciones” (errores) Implementa lógica de chequeo: cuando el agente propone una acción (por ejemplo: cambiar un pedido, dar un descuento), que haya un mecanismo de verificación, auditoría o aprobación humana antes de ejecutar.
Integración con distintos sistemas (API, SDK) Diseña los agentes como servicios modularizados: un agente puede tener interfaz API, SDK para que otros módulos del ERP lo invoquen, o usar webhook/eventos.
Enfoque orientado a “agentes que hacen cosas”, no solo “responden preguntas” Si tu ERP va a tener agentes activos (por ejemplo, que puedan crear órdenes, asignar tareas, autorecordar clientes), define claramente sus “roles” (qué pueden hacer), sus “gatillos” (cuándo actúan) y sus “límites” (qué no pueden hacer sin supervisión).
🔍 Qué partes del modelo de Lamini podrían no aplicar o requieren adaptación

Lamini es para casos de uso con equipos de IA e infraestructura fuerte; si tu ERP y tus agentes no necesitan ese nivel de complejidad, puedes optar por una versión más sencilla.

La monetización, licenciamiento, modelo “plataforma completa” quizás sea sobredimensionado para tu contexto de ERP.

Cuidado con promesas de “0 errores” o “sin alucinaciones”: en agentes de negocios siempre habrá excepciones, condiciones límite, datos sucios, etc. Mejor diseñar pensando en supervisión y mejora iterativa.

Si quieres, puedo armar un esquema/diseño concreto para tu ERP basado en los “patrones” que Lamini usa, con estructuras de datos, módulos de agente, flujos de interacción — lo más aterrizado posible para que lo puedas implementar (o al menos planificar) cuando llegue el momento. ¿Te lo preparo?

Vamos al grano: te dibujo un “Lamini-style” pero aterrizado a tu ERP con agentes que hacen cosas, no solo chatean.

1. Vista general: capas que necesitas

Piensa en tu ERP con agentes como esto:

Capa 0 – ERP núcleo
Pedidos, productos, clientes, pagos, etc. (lo que ya tienes o tendrás con Vendure + demás servicios).

Capa 1 – Bus de eventos
Todo lo importante dispara eventos:
OrderCreated, OrderPaid, StockBelowThreshold, LoginFailed, etc.

Capa 2 – Orquestador de agentes
Servicio que:

Recibe eventos.

Decide qué agente(s) deben reaccionar.

Les pasa contexto (datos del ERP).

Recibe de vuelta intenciones (acciones propuestas).

Las valida y las envía al ERP (o pide aprobación humana).

Capa 3 – Agentes (LLM + reglas)
Cada agente tiene:

Un rol (ej: “Agente Antifraude”, “Agente Inventario”, “Agente Soporte”).

Un conjunto de herramientas (API del ERP, consultas, acciones).

Una memoria / conocimiento (políticas, límites, reglas de negocio).

Guardrails: qué está prohibido hacer.

Capa 4 – Auditoría y supervisión
Todo lo que el agente decide y ejecuta queda logueado:

Qué evento disparó la acción.

Qué contexto vio.

Qué dijo el modelo.

Qué se ejecutó realmente.

Quién aprobó (si había aprobación humana).

Capa 5 – Interfaz humana
Panel donde tú ves:

Sugerencias de agentes pendientes de aprobar.

Acciones ejecutadas automáticamente.

Alertas de riesgo, errores, anomalías.

Un diagrama tipo:

flowchart LR
subgraph ERP[ERP Núcleo]
A[Pedidos] --> B[Pagos]
A --> C[Inventario]
A --> D[Clientes]
end

    ERP --> E[(Bus de Eventos)]

    subgraph Orq[Orquestador de Agentes]
        E --> F[Router de eventos]
        F --> G[Selector de agentes]
    end

    subgraph Agentes
        H1[Agente Antifraude]
        H2[Agente Inventario]
        H3[Agente Soporte]
    end

    G --> H1
    G --> H2
    G --> H3

    subgraph Tools[Herramientas / APIs ERP]
        T1[Leer datos ERP]
        T2[Crear/editar pedidos]
        T3[Modificar stock]
        T4[Enviar notificaciones]
    end

    H1 --> Tools
    H2 --> Tools
    H3 --> Tools

    Tools --> I[(Auditoría / Logs)]

    I --> J[Panel de revisión humana]

2. Modelo mínimo que debes guardar (inspirado en Lamini)
   2.1. Definición de Agente

Tabla / estructura Agent:

id

name – “Agente Antifraude Pedidos”

role – descripción clara de qué hace y qué NO hace.

allowed_tools – lista de APIs/herramientas que puede usar.

max_auto_action_level – hasta dónde puede actuar sin humano:

NONE = solo sugiere.

LOW = cambios menores (ej: etiquetas).

MEDIUM = puede bloquear temporalmente algo.

HIGH = puede cancelar pedidos / mover dinero (idealmente nunca sin supervisor).

risk_domain – fraude, inventario, soporte, etc.

llm_profile_id – con qué modelo/configuración corre (similar a “modelo fine-tune” en Lamini).

2.2. “Memoria” / conocimiento del agente

Tabla AgentMemory (inspirando el “memory tuning”):

id

agent_id

type – RULE, FAQ, THRESHOLD, PLAYBOOK.

content – texto estructurado (YAML/JSON/Markdown) con las reglas de negocio.

version

active – sí/no.

Ejemplo de contenido (texto, no código ejecutable):

type: RULE
name: descuento_maximo_sin_aprobacion
details:
canal: "ecommerce"
max_descuento_porcentaje: 10
requiere_aprobacion_por_encima: true

Tus agentes consultan estas “memorias” para tomar decisiones coherentes con tu negocio, igual que Lamini usa datos internos para afinar el modelo.

2.3. Registro de tareas y acciones

Tabla AgentTask (cada “caso” que maneja un agente):

id

agent_id

trigger_event – OrderCreated, StockBelowThreshold, etc.

input_context_snapshot – JSON con los datos que vio el agente.

proposed_actions – lista de acciones sugeridas por el modelo (texto estructurado).

final_actions – lista de acciones realmente ejecutadas.

status – PENDING_REVIEW, APPROVED, AUTO_EXECUTED, REJECTED.

reviewer_user_id – si alguien humano intervino.

created_at, updated_at.

Tabla AgentAction (si quieres más granularidad):

id

task_id

action_type – TAG_ORDER, BLOCK_ORDER, ADJUST_STOCK, SEND_EMAIL, etc.

target_entity – order:123, product:456, etc.

payload – detalles (ej: “bajar stock a 8”, “enviar correo X”).

executed – bool.

executed_at

execution_result – success/error.

Esto te da auditoría completa: justo lo que quieres para antifraude / UEBA.

3. Ciclo de vida de una acción de agente

Ejemplo para un pedido nuevo:

Evento del ERP
Se crea un pedido ⇒ OrderCreated va al bus de eventos.

Orquestador
El router ve:

event_type = OrderCreated

payment_method = tarjeta

order_total > 500 USD
Decide: “esto va al Agente Antifraude y al Agente CRM”.

Construcción de contexto
El orquestador arma un JSON de contexto:

Datos del pedido.

Historial del cliente.

IP / país / dispositivo.

Historial de devoluciones, chargebacks, etc.

Llamada al agente
El agente recibe:

role + instrucciones del sistema.

memoria (reglas antifraude, umbrales).

contexto.

El LLM devuelve algo estilo:

{
"risk_score": 0.82,
"proposed_actions": [
{
"action_type": "FLAG_ORDER",
"reason": "País de tarjeta distinto a país de envío y ticket alto"
},
{
"action_type": "REQUIRE_MANUAL_REVIEW"
}
]
}

Validación / políticas
El orquestador mira:

risk_score > 0.8

max_auto_action_level del agente.
Si no puede cancelar solo, entonces:

Marca el pedido como “En revisión”.

Manda la tarea a un humano en el panel.

Revisión humana (si aplica)
Tú o alguien mira el panel:

Ve el contexto.

Ve lo que propuso el agente.

Acepta o rechaza.

Ejecución
El orquestador llama a las herramientas:

API del ERP para actualizar estado de pedido.

Notificar por email al cliente si se rechaza, etc.

Auditoría
Todo queda en AgentTask + AgentAction:

Útil para explicar decisiones, entrenar mejor modelos, y para UEBA.

Este flujo lo puedes copiar para otros agentes: inventario, soporte, marketing, etc.

4. Patrones de seguridad y “antialucinaciones”

Inspirado en la idea de Lamini de reducir errores:

Prohibir SQL / cambios directos por LLM
El LLM nunca toca la base de datos.
Solo puede:

Proponer acciones estructuradas (JSON).

Llamar herramientas que tú controlas (APIs con validaciones).

Contrato de salida estricto
Siempre obligas al modelo a responder con un esquema fijo:
risk_score, proposed_actions[], comments.
Nada de textos sueltos para ejecutar directamente.

Simulación (dry-run)
Tal como quieres en tus scripts:

Tener un modo “simulación” donde el agente:

Registra lo que habría hecho.

No ejecuta nada.

Perfecto para probar nuevas reglas o nuevos modelos.

Reglas duras fuera del modelo
Cosas como:

“Nunca cancelar pedido pagado manualmente sin revisión humana”.

“Nunca bajar stock por debajo de 0”.
Eso va en código/reglas duras, no en el modelo.

Limitar ámbitos
Cada agente debe tener:

Herramientas específicas.

Entidades permitidas.

Acciones máximas por minuto / por hora.
Evita que una ida de olla del modelo haga un destrozo masivo.

5. Ejemplos concretos de agentes para tu ERP
   5.1. Agente Antifraude interno (UEBA lite)

Se apoya en:

Eventos: LoginFailed, UnusualIP, MassiveDiscountApplied, BulkExportRun.

Contexto:
quién fue, desde dónde, qué rol, qué dispositivo, qué cambios intentó.

Acciones:

Marcar sesión como de riesgo.

Obligar a MFA.

Bloquear descuentos de esa cuenta hasta revisión.

Crear “caso de seguridad” para revisión manual.

Es el puente entre tus ideas de UEBA y los agentes.

5.2. Agente de Inventario / PIM

Eventos: StockBelowThreshold, NewProductScraped, PriceChangeFromSupplier.

Acciones:

Proponer nuevas cantidades de compra.

Etiquetar productos “riesgo de stockout”.

Sincronizar catálogos entre tiendas (pero con revisión humana para cambios masivos).

5.3. Agente de Soporte / Atención

Eventos: NewSupportTicket, OrderStatusRequested.

Acciones:

Proponer respuesta pre-llenada usando políticas y FAQ.

Ofrecer compensación dentro de límites definidos (memoria de políticas).

Crear tareas internas si detecta problemas repetidos.

6. Qué te llevas de Lamini, traducido a tu mundo

Ellos: fine-tuning y “memory tuning” sobre datos de empresa.
Tú: tablas de AgentMemory y datos internos bien organizados que los agentes consulten para tomar decisiones.

Ellos: despliegues controlados, seguridad empresarial.
Tú: capa de orquestador con políticas fuertes y logs completos.

Ellos: plataforma para crear agentes que entienden muy bien el negocio.
Tú: ERP con agentes verticales (fraude, inventario, soporte) que usan tus propios datos, reglas y límites.

Todo esto lo puedes ir incorporando por fases: primero solo modo simulación + sugerencias, luego acciones automáticas de bajo riesgo, después cosas más críticas cuando ya confíes en el sistema y en tus reglas.
