{{/*
Expand the name of the chart.
*/}}
{{- define "hcce.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hcce.fullname" -}}
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
{{- define "hcce.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hcce.labels" -}}
helm.sh/chart: {{ include "hcce.chart" . }}
{{ include "hcce.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hcce.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hcce.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hcce.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hcce.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
       ### Make the certs using Sprig functions  ###
*/}}

{{- define "hcce.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" (include "hcce.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "hcce.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "hcce-ca" 36500 -}}
{{- $cert := genSignedCert ( include "hcce.name" . ) nil $altNames 36500 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{/*
Generate self-signed certificates for your domain and subdomains
*/}}
{{- define "domain-certs.gen-certs" -}}
{{- $altNames := list "*.localhost" "localhost" "127.0.0.1" -}}
{{- $ca := genCA "hcce-ca" 36500 -}}
{{- $cert := genSignedCert "localhost" nil $altNames 36500 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}