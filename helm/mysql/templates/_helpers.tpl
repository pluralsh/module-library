{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mysql-cluster.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mysql-cluster.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mysql-cluster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mysql-cluster.dbConnectURL" -}}
mysql://
{{- if .Values.appUser -}}
    {{ urlquery .Values.appUser -}}
    {{- if .Values.appPassword -}}
        :{{ urlquery .Values.appPassword }}
    {{- end -}}
@
{{- end -}}
{{- include "mysql-cluster.clusterName" . -}}-mysql-master:3306
{{- if .Values.appDatabase -}}
/{{- .Values.appDatabase -}}
{{- end -}}
{{- end -}}

{{- define "mysql-cluster.clusterName" -}}
{{- if .Values.clusterNameOverride -}}
{{ .Values.clusterNameOverride }}
{{- else -}}
{{- printf "%s-db" (include "mysql-cluster.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "mysql-cluster.secretName" -}}
{{- printf "%s-db" (include "mysql-cluster.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mysql-cluster.backupSecretName" -}}
{{- printf "%s-db-backup" (include "mysql-cluster.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "mysql-cluster.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mysql-cluster.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mysql-cluster.labels" -}}
helm.sh/chart: {{ include "mysql-cluster.chart" . }}
{{ include "mysql-cluster.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mysql-cluster.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mysql-cluster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
