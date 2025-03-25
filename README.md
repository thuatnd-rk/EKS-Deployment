Dưới đây là file `README.md` đầy đủ, đã tích hợp phần **khởi tạo RDS MySQL**, đưa phần **Architecture Diagram** lên đầu, và định dạng rõ ràng để bạn dùng trực tiếp:

---

```md
# 📦 User Management Application on Amazon EKS

## 📷 Architecture Diagram

![EKS Architecture](./imgs/aws-eks-alb-ingress-context-path-based-routing.png "EKS Deployment Diagram")

---

## 🛠️ Step 0: Create RDS MySQL Database (Pre-requisite)

Before deploying the microservice, we need a MySQL database running in **Amazon RDS**. Follow these steps:

### ✅ 1. Review Your EKS VPC

- Go to **AWS Console → VPC**
- Identify the VPC used by your EKS Cluster  
  Example: `example-VPC`

---

### ✅ 2. Create Security Group for RDS

- Go to **VPC → Security Groups → Create Security Group**
- **Name:** `eks_rds_db_sg`
- **Description:** Allow access for RDS Database on Port 3306
- **VPC:** `example-VPC`

**Inbound Rules:**
- **Type:** MySQL/Aurora
- **Protocol:** TCP
- **Port:** 3306
- **Source:** Anywhere (`0.0.0.0/0`)
- **Description:** Allow access for RDS Database (Labs only)

**Outbound Rules:**
- Leave as default (Allow All)

---

### ✅ 3. Create DB Subnet Group

- Go to **RDS → Subnet Groups → Create DB Subnet Group**
- **Name:** `eks-rds-db-subnetgroup`
- **Description:** EKS RDS DB Subnet Group
- **VPC:** `example-VPC`
- **Availability Zones:** `us-east-1a`, `us-east-1b`
- **Subnets:** Choose 2 private subnets in the 2 different AZs
- Click **Create**

---

### ✅ 4. Create the RDS MySQL Database

- Go to **RDS → Databases → Create Database**
- **Creation Method:** Standard Create
- **Engine:** MySQL
- **Version:** 8.0.40
- **Template:** Free Tier
- **DB Identifier:** `usermgmtdb`
- **Master Username:** `dbadmin`
- **Master Password:** `dbpassword11`
- **Instance Size / Storage:** Leave as default

**Connectivity:**
- **VPC:** `example-VPC`
- **DB Subnet Group:** `eks-rds-db-subnetgroup`
- **Public Access:** `No`
- **VPC Security Group:** Select `eks_rds_db_sg`
- **Port:** 3306

Click **Create Database**

👉 **After DB is ready**, update the `externalName` in `01-MySQL-externalName-Service.yml`:

```yaml
externalName: <your-db-endpoint>.rds.amazonaws.com
```

### ✅ 5. Create usermgmt Database Schema in RDS
Once the RDS instance is available, connect to it using a temporary MySQL client pod in Kubernetes:

```bash
kubectl run -it --rm --image=mysql:5.7.22 --restart=Never mysql-client -- \
  mysql -h <your-db-endpoint>.rds.amazonaws.com -u dbadmin -pdbpassword11
```

🔄 Replace `<your-db-endpoint>` with the actual endpoint (e.g., `usermgmtdb.c7hldelt9xfp.us-east-1.rds.amazonaws.com`)

Inside the MySQL shell:

```sql
SHOW SCHEMAS;
CREATE DATABASE usermgmt;
SHOW SCHEMAS;
EXIT;
```

---

## 📁 Project Structure

| File | Description |
|------|-------------|
| `01-MySQL-externalName-Service.yml` | ExternalName service for RDS MySQL |
| `02-UserManagementMicroservice-Deployment-Service.yml` | Microservice Deployment & environment variables |
| `03-Kubernetes-Secrets.yml` | Secret for DB password |
| `04-UserManagement-NodePort-Service.yml` | NodePort service for microservice |
| `05-Nginx-App1-Deployment-and-NodePortService.yml` | App1 (NGINX) deployment and service |
| `06-Nginx-App2-Deployment-and-NodePortService.yml` | App2 (NGINX) deployment and service |
| `07-ALB-Ingress-Basic.yml` | ALB Ingress with path-based routing |

---

## 🚀 Deployment Guide

### 1. Apply ExternalName Service for RDS

```bash
kubectl apply -f 01-MySQL-externalName-Service.yml
```

---

### 2. Create Kubernetes Secret

```bash
kubectl apply -f 03-Kubernetes-Secrets.yml
```

---

### 3. Deploy User Management Microservice

```bash
kubectl apply -f 02-UserManagementMicroservice-Deployment-Service.yml
kubectl apply -f 04-UserManagement-NodePort-Service.yml
```

---

### 4. Deploy NGINX Applications

```bash
kubectl apply -f 05-Nginx-App1-Deployment-and-NodePortService.yml
kubectl apply -f 06-Nginx-App2-Deployment-and-NodePortService.yml
```

---

### 5. Setup ALB Ingress

```bash
kubectl apply -f 07-ALB-Ingress-Basic.yml
```

To get the ALB hostname:

```bash
kubectl get ingress
```

---

## ✅ Application Access

| Path | Service |
|------|---------|
| `/` | User Management Microservice (port 8095) |
| `/app1` | App1 NGINX (port 80) |
| `/app2` | App2 NGINX (port 80) |

---

## 🩺 Health Checks

- User Management: `/usermgmt/health-status`
- App1: `/app1/index.html`
- App2: `/app2/index.html`

Make sure these endpoints return `200 OK` for ALB health check success.

---

## 🔐 Security Notes

- DB credentials are stored securely using Kubernetes Secrets.
- ALB performs health checks and distributes traffic to backend services.
- RDS is made publicly accessible **only for learning purposes**.

---

## ⚠️ Additional Notes

- Ensure your RDS endpoint is correct and reachable from EKS nodes.
- Keep security group rules strict in production environments.
- ALB annotations must match services correctly for health checks and routing.

---
```

---

Bạn có muốn mình xuất file `.md` hoặc tạo file `.zip` để tải về dễ dàng không? Hoặc nếu bạn muốn bản tiếng Việt thì mình cũng có thể hỗ trợ nhé!