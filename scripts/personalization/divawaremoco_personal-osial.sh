#!/bin/bash
#SBATCH --job-name=FedSSL
#SBATCH --gpus=1
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=12
#SBATCH --ntasks=1
#SBATCH --partition=dgx
#SBATCH --qos=normal

##SBATCH --job-name=FedSSL_noftsh_6
##SBATCH --gpus=ampere:1
##SBATCH --mem-per-cpu=6G
##SBATCH --cpus-per-task=12
##SBATCH --ntasks=1

set -e
#eval "$(conda shell.bash hook)"
#conda activate uj
#source /home/gmosial/miniconda3/bin/activate /home/gmosial/miniconda3/envs/mae_env
#source /raid/NFS_SHARE/home/marcin.osial/miniconda3/bin/activate /raid/NFS_SHARE/home/marcin.osial/miniconda3/envs/maenv
set -x

#cd "$(dirname "$0")"
#cd ../../
export WANDB_API_KEY=f61fe6de67dc18515ebe11ca944faaa2ccdd11e1
export WANDB__SERVICE_WAIT=300
export WANDB_PROJECT=federated_ssl
export WANDB_ENTITY=gmum

#fixed arguments
num_epoch=20
lr=0.06
moco_version=V2
arch=ResNet18

#non_iid_list="0.2 1.0"
noniid_ratio="1.0" #"0.2"
#cutlayer_list="1" # 2"
#num_client="20"
num_client=6
K=4100
dataset=domainnet
data_proportion=1.0
num_workers=12
batch_size=100
loss_threshold=0.0
ressfl_alpha=0.0
bottleneck_option=None


prefix="mocosfl${moco_version}_${arch}_${dataset}_bnl${bottleneck_option}_client${num_client}_nonIID${noniid_ratio}_K${K}"
constant_args="--num_client ${num_client} --lr ${lr} --num_epoch ${num_epoch} --noniid_ratio ${noniid_ratio}  --moco_version ${moco_version} \
  --arch ${arch} --dataset ${dataset} --loss_threshold ${loss_threshold} --ressfl_alpha ${ressfl_alpha} --bottleneck_option ${bottleneck_option}
  --auto_adjust --divergence_measure --K $K --data_proportion ${data_proportion} --batch_size ${batch_size} --num_workers ${num_workers}"

#cutlayer=3

DIV_LAMBDA=1
for cutlayer in 6;
do

# output_dir="./outputs/${prefix}_cut${cutlayer}_baseline"
# python run_sflmoco.py  $constant_args --cutlayer ${cutlayer} --output_dir ${output_dir}
#
 output_dir="./outputs/${prefix}_cut${cutlayer}_no-ft-sharing_domainnet"
 python run_sflmoco.py  $constant_args --cutlayer ${cutlayer} --output_dir ${output_dir} --disable_feature_sharing

#output_dir="./outputs/${prefix}_cut${cutlayer}_fix-div-aware_lambda${DIV_LAMBDA}"
#python run_sflmoco.py  $constant_args --cutlayer ${cutlayer} --output_dir ${output_dir} --div_lambda $DIV_LAMBDA --divergence_aware --div_layerwise fraction
#
#output_dir="./outputs/${prefix}_cut${cutlayer}_div-aware_no-ft-sharing"
#python run_sflmoco.py  $constant_args --cutlayer ${cutlayer} --output_dir ${output_dir} --disable_feature_sharing --divergence_aware

done