ARG ROS_DISTRO=humble

FROM ros:${ROS_DISTRO}-ros-base AS builder

WORKDIR /colcon_ws

RUN git clone https://github.com/stereolabs/zed-ros2-interfaces.git src/zed_interfaces && \
    . /opt/ros/${ROS_DISTRO}/setup.sh && \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release --event-handlers console_direct+




FROM ros:${ROS_DISTRO}-ros-core

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-foxglove-bridge \
    ros-${ROS_DISTRO}-tf2-msgs \
    ros-${ROS_DISTRO}-rosapi-msgs \
    ros-${ROS_DISTRO}-geometry-msgs \
    ros-${ROS_DISTRO}-sensor-msgs \
    ros-${ROS_DISTRO}-rosbridge-msgs \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /colcon_ws/install/zed_interfaces /opt/ros/${ROS_DISTRO}

COPY ros_entrypoint.sh .

RUN echo 'source /opt/ros/humble/setup.bash; ros2 launch foxglove_bridge foxglove_bridge_launch.xml' >> /run.sh && chmod +x /run.sh
RUN echo 'alias run="su - ros /run.sh"' >> /etc/bash.bashrc
