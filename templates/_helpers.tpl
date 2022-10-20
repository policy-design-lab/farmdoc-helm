{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "farmdoc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "farmdoc.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "farmdoc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "farmdoc.labels" -}}
helm.sh/chart: {{ include "farmdoc.chart" . }}
{{ include "farmdoc.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "farmdoc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "farmdoc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "farmdoc.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "farmdoc.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Ingress annotations
traefik.ingress.kubernetes.io/whitelist-source-range: "141.142.0.0/16"
*/}}
{{- define "farmdoc.authIngressAnnotation" }}
{{- if .Values.ingress.traefik -}}
traefik.ingress.kubernetes.io/router.middlewares: {{ .Release.Namespace }}-auth@kubernetescrd
{{- else }}
ingress.kubernetes.io/auth-type: forward
ingress.kubernetes.io/auth-url: http://{{ include "farmdoc.fullname" . }}-auth.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.auth.service.port }}/
ingress.kubernetes.io/auth-trust-headers: "true"
ingress.kubernetes.io/auth-response-headers: x-auth-userinfo, X-Auth-Userinfo, x-auth-usergroup, X-Auth-UserGroup
{{- end }}
{{- end }}

{{/*
Create the mongodb uri to use
*/}}
{{- define "farmdoc.mongodb.uri" -}}
{{- printf "mongodb://root:%s@%s-mongodb:27017/%s?maxpoolsize=100&authSource=admin" .Values.mongodb.auth.rootPassword (include "farmdoc.fullname" .) "@DB@" }}
{{- end }}
