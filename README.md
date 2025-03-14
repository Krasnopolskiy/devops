# Лабораторные работы по курсу "Технологии оркестрации"

> Вариант №108

## Git

Git является основным инструментом контроля версий в разработке и DevOps. В этом задании необходимо развернуть
Git-сервер на виртуальной машине (ВМ) и настроить его для совместной работы команды. Это позволит хранить и управлять
кодом приложения, а также интегрировать его в процесс CI/CD.

### Задание

Разверните и настройте [Gogs](https://gogs.io/) на виртуальной машине при помощи **Docker Compose**.

Используя [официальный образ](https://hub.docker.com/r/gogs/gogs) и зависимости
из [инструкции по установке](https://gogs.io/docs/installation), создайте docker-compose.yml для его развертки.

## Container Registry

Container Registry позволяет хранить и управлять контейнерными образами, необходимыми для развертывания приложений. В
этом задании необходимо установить и настроить приватный реестр контейнеров, который будет использоваться для хранения
образов вашего приложения.

### Задание

Разверните и настройте [Harbor](https://goharbor.io/) при помощи **Docker Compose**.

Harbor не имеет официальной конфигурации docker compose. Поэтому создать файл docker-compose.yml придется
самостоятельно.

Рекоммендации по написанию docker-compose.yml:

- учтите, что Harbor имеет микросервисную архитектуру
- изучите и используйте [официальную документацию](https://goharbor.io/docs/) по установке
- изучите [готовые Helm charts](https://github.com/goharbor/harbor-helm) для деплоя в Kubernetes
- изучите и используйте [официальные образы Harbor](https://goharbor.io/docs/2.0.0/install-config/download-installer/)

Проверьте работу развернутого Harbor.

## Kubernetes

Kubernetes — это система оркестрации контейнеров, позволяющая управлять развертыванием, масштабированием и обновлением
приложений. В этом задании необходимо развернуть кластер Kubernetes из двух виртуальных машин (мастер и рабочий узел) и
настроить его для работы с контейнерными приложениями.

### Задание

- Разверните и настройте Kubernetes кластер при помощи официального дистрибутива [K8S](https://kubernetes.io/)
  и [Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/),
  следуя [официальной документации](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).
- Установите и настройте [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) на локальной машине для
  доступа к кластеру.
- Задеплойте [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) на
  свой кластер,
  следуя [официальной инструкции](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/).

## Provisioning

Автоматизация установки Kubernetes ускоряет процесс развертывания и упрощает управление кластерами. В этом задании
необходимо написать скрипты для автоматизированного развертывания Kubernetes, используя инструменты конфигурационного
управления.

### Задание

Автоматизируйте развертку Kubernetes кластера при помощи [Puppet](https://puppet.com/).
Следуйте [официальной документации](https://puppet.com/docs) Puppet.

- Разверните Puppet Server на локальную машину или отдельную виртуальную машину.
- Разверите Puppet agent на узлах кластера.
- Напишите конфигурации по автоматической развертке Kubernetes кластера на узлах.

## Приложение

В этом задании необходимо задеплоить простое приложение на виртуальную машину используя docker compose.

Необходимо:

- ознакомиться с приложением
- скопировать его на свой Git сервер
- написать Dockerfile для сборки образа приложения
- написать docker-compose.yml для деплоя приложения вместе с его зависимостями
- задеплоить приложение на виртуальную машину при помощи docker-compose

### Задание

В своей работе используйте приложение [Todo](https://github.com/docker/docker-birthday-3/tree/master/app). Все
зависимости и инструкции по сборке указаны в README репозитория.

## Continuous Integration

Непрерывная интеграция (Continuous Integration, CI) позволяет автоматизировать процесс тестирования и сборки приложения.
В этом задании необходимо развернуть инструмент CI, настроить сборку контейнерного образа и его тестирование перед
публикацией.

Для хранения собранных образов используйте развернутый Container Registry.

Для CI необходимо реализовать следущие шаги:

- Сборка приложения
- Запуск проверки качества кода (linting)
- Запуск тестов

### Задание

Для настройки CI pipeline используйте [Jenkins](https://jenkins.io/).
Следуйте [официальной документации](https://jenkins.io/doc/)

- Изучите документацию.
- Разверните Jenkins controller и Jenkins agent при помощи **Docker Compose*- на одной из виртуальных машин.
- Настройте Jenkins.
- Подключите Jenkins к Gogs при помощи [плагина](https://plugins.jenkins.io/gogs-webhook/).
- Настройте CI pipeline для приложения ориентируясь на [официальную документацию](https://jenkins.io/doc/pipeline/)

## Deployment

Для автоматического развертывания приложения в Kubernetes используются манифесты и конфигурационные файлы. В этом
задании необходимо написать YAML-манифесты для деплоя приложения, настройки сетевых политик, управления ресурсами и
обновления версий.

### Задание

Используйте [Helm](https://helm.sh/) для деплоя приложения в Kubernetes.

- Установите Helm на локальную машину следуя [официальной документации](https://helm.sh/docs/intro/install/).
- Добавьте Helm Charts в проект
  следуя [официальной документации](https://helm.sh/docs/chart_template_guide/getting_started/).
- Задеплойте приложение в Kubernetes для проверки конфигурации.

Все конфигурации следует сохранять в git репозиторий.

## Continuous Deployment

Непрерывный деплоймент (Continuous Deployment, CD) позволяет автоматизировать развертывание новых версий приложения в
Kubernetes. В этом задании необходимо настроить CD-процесс, чтобы изменения в репозитории автоматически применялись в
кластере.

Для получения собранных образов используйте развернутый Container Registry.

### Задание

Для создания CD pipeline используйте [Argo CD](https://argoproj.github.io/cd/).

- Изучите [документацию](https://argoproj.github.io/argo-cd/docs/getting_started/).
- Разврените Argo CD в Kubernetes
  следуя [официальной документации](https://argoproj.github.io/argo-cd/getting_started/).
- Настройте Argo CD и интегрируйте его с развернутым git сервером.
- Настройте CD pipeline для автоматического деплоя приложения в Kubernetes с использованием Argo CD.

## Логирование

Логирование критически важно для отладки и мониторинга приложений. В этом задании необходимо развернуть и настроить
систему сбора логов, чтобы отслеживать состояние узлов кластера, Kubernetes и приложения.

### Задание

В качестве системы сбора логов используйте [OpenSearch стек](https://opensearch.org/):

- [FluentBit](https://fluentbit.io/) - сборщик логов
- [OpenSearch Data Prepper](https://opensearch.org/docs/latest/data-prepper/index/) - структурирует логи и отправляет в
  OpenSearch Core
- [OpenSearch Core](https://opensearch.org/docs/latest/opensearch/index/) - хранит и индексирует логи
- [OpenSearch Dashboards](https://opensearch.org/docs/latest/dashboards/index/) - система визуализации логов

### Инструкция

- Изучите [документацию OpenSearch](https://opensearch.org/docs/latest/)
- Разверните OpenSearch на кластере Kubernetes
  следуя [инструкции](https://opensearch.org/docs/latest/opensearch/install/index/).
- Разверните OpenSearch Dashboards на кластере Kubernetes
  следуя [инструкции](https://opensearch.org/docs/latest/dashboards/install/index/).
- Изучите и настройте OpenSearch.
- Изучите [документацию FluentBit](https://docs.fluentbit.io/manual).
- Разверните FlutentBit на каждом из узлов кластера
  следуя [документации](https://docs.fluentbit.io/manual/installation/kubernetes).
- Настройте FlutentBit на сбор системных логов, логов Kubernetes кластера и приложения.
- Разверните и настройте OpenSearch Data Prepper при помощи docker
  следуя [инструкции](https://opensearch.org/docs/latest/data-prepper/getting-started/).
- Настройте pipeline для OpenSearch Data Prepper для забора логов из FluentBit.
- Создайте Dashboard в OpenSearch Dashboards для отображения логов.

## Мониторинг

Мониторинг позволяет отслеживать производительность и стабильность системы. В этом задании необходимо развернуть
инструменты для сбора метрик узлов кластера, Kubernetes и приложения, а также визуализировать их в удобном интерфейсе.

### Задание

В качестве системы сбора метрик используйте [Victoria Metrics](https://victoriametrics.com/). Для сбора метрик с узлов
кластера используйте [Prometheus NodeExporter](https://github.com/prometheus/node_exporter). Для отправки алертов
используйте [Prometheus AlertManager](https://prometheus.io/docs/alerting/latest/alertmanager/).

### Инструкция

- Разверните NodeExporter на каждом из узлов кластера
  следуя [инструкции](https://prometheus.io/docs/guides/node-exporter/).
- Изучите официальную [документацию](https://docs.victoriametrics.com/)
- Задеплойте Vicotria Metrics в Kubernetes при
  помощи [официальных Helm Charts](https://github.com/VictoriaMetrics/helm-charts)
- Настройте Victoria Metrics для сбора следующих метрик:
    - метрики всех NodeExporter
    - метрики Kubernetes кластера
    - метрики приложения.
- Создайте Dashboard в Victoria Metrics для отображения метрик.
- Самостоятельно напишите Helm Chart для деплоя Prometheus AlertManager в Kubernetes ориентируясь
  на [документацию](https://prometheus.io/docs/alerting/latest/configuration/).
- Рзаверните AlertManager в Kubernetes кластере.
- Настройте AlertManager на отправку сообщений по любому из каналов (Email/Telegram/Discord/Roketchat и т.д.)
  следуя [документации](https://prometheus.io/docs/alerting/latest/configuration/).
- Настройте компонент Victoria Metrics - [vmalert](https://docs.victoriametrics.com/vmalert/) и добвьте хотя бы один
  алерт для отправки в AlertManager
