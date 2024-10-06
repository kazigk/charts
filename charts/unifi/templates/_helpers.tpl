{{/*
Expand the name of the chart.
*/}}
{{- define "unifi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "unifi.fullname" -}}
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
{{- define "unifi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "unifi.labels" -}}
helm.sh/chart: {{ include "unifi.chart" . }}
{{ include "unifi.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "unifi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "unifi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "unifi.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "unifi.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
MongoDB secrets
*/}}
{{- define "unifi.mongoRootSecret" -}}
{{ include "mongodb.fullname" .Subcharts.mongodb }}
{{- end }}
{{- define "unifi.mongoUserSecret" -}}
{{ include "unifi.fullname" . }}-mongodb-user
{{- end }}

{{/*
Common environment variables
*/}}
{{- define "unifi.commonEnv" -}}
{{- if .Values.mongodb.enabled -}}
- name: MONGO_HOST
  value: {{ include "mongodb.service.nameOverride" .Subcharts.mongodb }}
- name: MONGO_PORT
  value: {{ quote .Values.mongodb.service.ports.mongodb }}
{{- else -}}
- name: MONGO_HOST
  value: {{ .Values.database.host }}
- name: MONGO_PORT
  value: {{ quote .Values.database.port }}
{{- end }}
- name: MONGO_DBNAME
  value: {{ .Values.database.name }}
- name: MONGO_AUTHSOURCE
  value: {{ .Values.database.authSource }}
- name: MONGO_USER
  valueFrom:
    secretKeyRef:
      name: {{ include "unifi.mongoUserSecret" . }}
      key: username
- name: MONGO_PASS
  valueFrom:
    secretKeyRef:
      name: {{ include "unifi.mongoUserSecret" . }}
      key: password
{{- end -}}
