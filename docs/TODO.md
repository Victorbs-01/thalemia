1. instalar claude code, ready
2. Que es lo primero que deberia revisar claude code ? ready
3. Tenemos todas las revisiones de codigo necesarias para esta etapa? ready, se aliviano la politica de pullrequest.
4. Que revisiones de codigo deberiamos agregar en el futuro
5. Que documentacion necesita claude para operar mejor con el repo
6. Que deberiamos agregar en el setting.json de la carpeta .claude ?
7. que hooks deberiamos agregar
8. crear el servidor de DO con el sistema de VPN para que dv01 pueda entrar y ser host de red
9. el servidor tendria que ser en linode, con terraform, y considerar la estructura del stack para monitorearlo,
10. crear la red, en espera de router y cables
11. poner a trabajar dev02 dev04 dev05
12. formatear y poner a trabajar dev03 cuando este listo el vpn.
13. Instalar las herramientas de gestion de Cloud
14. Armar el cloud con nuestro stack local, para servir Maestro de producto y tiendas online
15. Instalar nuestro Helk, planear la mejor forma de volverlo producto
16. ver como mejorar el HELK, para captura de incidentes demodo automatico, que sea totalmente automatizado
17. La idea del helk es que trabaje 1 persona o menos en el con todo automatico y un excelente dashboard
18. ver montar el mcp-git con gitea+drone. - Qodana - sonarqube - Trivy MinIO Drone Autoscaler Vault (cuando tengas producción)
19. montar sistemas antifraude anclarlos a helk, para medir uso de recursos humanos
20. SOC + NOC + DLP + UEBA - https://openuba.org/
21. ojo con la estrategia i18n, todo debe ser traducible
22. montar el maestro de productos con vendure-PIM
23. Crear el front del maestro de productos con la tienda de muestra de vercel vendure o evaluar - https://vendure-tanstack-starter.netlify.app/
24. Montar el vendure-shop, montar las tiendas de china online market
25. Montar n8b y crear los flujos para poblar el maestro de productos
26. crear los flujos entre los vendures para poblar tiendas
27. monitorear todo esto con nuestros sistemas
28. Agregar erpnext para el manejo del recurso humano RRHH o ver opciones mas potentes.
29. Crear el flujo de chat, usar un chatbotautomatico en vendure-shop - https://www.botpress.com/
30. ver que el chat tenga idealmente whatsapp, facebook. tiktok, instagram, wechat, telegram, zalo, line
31. crear el flujo de captura de clientes, add on en vendure-shop, por rubro por pais
32. crear el sistema de mejora en vendure-pim, mejorar los textos y los datos de los productos, peso tamano
33. Crear el sistema de proveedores en vendure-pim, listarlos, compararlos, por precio localizacion y disponibilidades para comprar los items,
34. estados de los proveedores, nuevos, nunca usados, probado, fallo en calidad, fallo en cumplimiento.
35. Crear el pluggin de envio en vendure-shop - usar este o mejores - https://goshippo.com/ - envios china al mundo ojo con latam
36. Habilitar en vendure shop, envio aereo o marino segun volumen y tamano de mercancia
37. Crear el pluggin de cotizaciones en vendure shop, habilidad para que el cliente cotice automaticamente
38. crear el pluggun de facturacion en vendure shop - algo asi como https://invoiceninja.com/ -
39. Ver la facturacion electronica por pais, boleta, factura, guia y nota de credito, ver china, ver Peru y ver chile, - esto puedo ser demoroso, se puede posponer o dejar en etapas
40. buscar sistemas para mejorar vendure shop -
41. • Advanced search powered by Typesense
    • Gift cards & store credit
    • Advanced wishlists (multiple, public - think Amazon style)
    • And more custom plugins such as reward (loyalty) points, geolocation, sitemap generation, custom redirects, featured filters, custom CMS and more
42. integracion de erpnext para llevar contabilidad inventarios o ver como reemplazarlo con algo mejor (inventarios y contabilidad,)
43. integracion de twenty para crm de clientes, como crm y helpdesk. todo pega con n8n
44. preguntas de clientes en los productos ancladas al CRM
45. en la facturacion o generacion de documentos, debe verse la guia de despacho
46. Modulo de garantias, garantia extendidas, devoluciones vendure-shop
47. Modulo kit de productos en vendure-shop - uso de ia para armar kit productos que van siempre juntos
48. creacion del dashboard de juegos, evaluar como realizarlo tipo LORD mobile - y esto https://chatdev.ai/
49. ver que el sistema tenga acciones automaticas de ia
50. pruebas en https://e2b.dev/ o docker, para ia que compra automaticamente
51. POS para tiendas, ver que tiene el opensourse
52. montaje de backend tipo shopify para clientes, pueden crear automaticamente sus tiendas.
53. Pluggin de blog para las tienes, vendure-shop con creacion automatica por rubro, y frecuencias
54. Pluggin de foro para tiendas, anidado al CRM para atencion de clientes
55. Sistema de capacitacion de clientes. similar al de claude, evaluar al cliente y tener su score en el sistema, entender su nivel de conocimiento
