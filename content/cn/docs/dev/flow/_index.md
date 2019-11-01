
---
title: "数据处理平台"
linkTitle: "数据处理平台"
weight: 1000
description: >
  数据处理平台负责大数据处理过程的调度和流程管理。
---

## 数据处理基本流程

<div class="mermaid">
graph LR
  n1(获取数据)
  n2(数据预处理)
  n3(模型计算)
  n4(数据汇总)
  
  n1 --> n2 --> n3 --> n4
</div>



## 系统截图

![](./img/data-flow-01.png)
