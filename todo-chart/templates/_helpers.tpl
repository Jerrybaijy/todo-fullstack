{{/* 定义 Chart 的名称，优先使用 Values.nameOverride，如果不存在则使用 Chart.Name */}}
{{- define "todo-chart.name" }}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* 定义 Chart 的完整标识，格式为 Chart.Name-Chart.Version */}}
{{- define "todo-chart.chart" }}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* 定义 Chart 的完整发布名称，优先使用 Values.fullnameOverride，如果不存在则根据 Release.Name 和 Chart.Name 生成 */}}
{{- define "todo-chart.fullname" }}
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

{{/* 生成 Cloud SQL 实例连接名称 */}}
{{- define "todo-chart.sqlInstanceConnectionName" -}}
{{- printf "%s:%s:%s" .Values.gcp.projectId .Values.gcp.region .Values.gcp.sqlInstanceName -}}
{{- end -}}

{{/* 定义 Backend 组件的完整名称 */}}
{{- define "todo-chart.backend.fullname" }}
{{- printf "%s-backend" (include "todo-chart.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* 定义 Frontend 组件的完整名称 */}}
{{- define "todo-chart.frontend.fullname" }}
{{- printf "%s-frontend" (include "todo-chart.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* 定义基础的标签集合，包含 Chart 信息和 Release 信息 */}}
{{- define "todo-chart.labels" }}
helm.sh/chart: {{ include "todo-chart.chart" . }}
helm.sh/version: {{ .Chart.Version | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels }}
{{- toYaml .Values.commonLabels | nindent 2 }}
{{- end }}
{{- end }}

{{/* 定义 Backend 组件的标签集合，继承基础标签并添加组件特定标签 */}}
{{- define "todo-chart.backend.labels" }}
{{- include "todo-chart.labels" . }}
app.kubernetes.io/name: {{ include "todo-chart.name" . }}-backend
app.kubernetes.io/component: backend
{{- end }}

{{/* 定义 Backend 组件的选择器标签，用于 Pod 选择 */}}
{{- define "todo-chart.backend.selectorLabels" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: {{ include "todo-chart.name" . }}-backend
app.kubernetes.io/component: backend
{{- end }}

{{/* 定义 Frontend 组件的标签集合，继承基础标签并添加组件特定标签 */}}
{{- define "todo-chart.frontend.labels" }}
{{- include "todo-chart.labels" . }}
app.kubernetes.io/name: {{ include "todo-chart.name" . }}-frontend
app.kubernetes.io/component: frontend
{{- end }}

{{/* 定义 Frontend 组件的选择器标签，用于 Pod 选择 */}}
{{- define "todo-chart.frontend.selectorLabels" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: {{ include "todo-chart.name" . }}-frontend
app.kubernetes.io/component: frontend
{{- end }}