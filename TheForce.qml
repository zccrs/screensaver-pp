import QtQuick.Particles 2.0
import QtQuick 2.0

//REGISTER_ACCESSOR(p, v4, x, initialX);
//REGISTER_ACCESSOR(p, v4, y, initialY);
//REGISTER_ACCESSOR(p, v4, t, t);
//REGISTER_ACCESSOR(p, v4, lifeSpan, lifeSpan);
//REGISTER_ACCESSOR(p, v4, size, startSize);
//REGISTER_ACCESSOR(p, v4, endSize, endSize);
//REGISTER_ACCESSOR(p, v4, vx, initialVX);
//REGISTER_ACCESSOR(p, v4, vy, initialVY);
//REGISTER_ACCESSOR(p, v4, ax, initialAX);
//REGISTER_ACCESSOR(p, v4, ay, initialAY);
//REGISTER_ACCESSOR(p, v4, xx, xDeformationVectorX);
//REGISTER_ACCESSOR(p, v4, xy, xDeformationVectorY);
//REGISTER_ACCESSOR(p, v4, yx, yDeformationVectorX);
//REGISTER_ACCESSOR(p, v4, yy, yDeformationVectorY);
//REGISTER_ACCESSOR(p, v4, rotation, rotation);
//REGISTER_ACCESSOR(p, v4, rotationVelocity, rotationVelocity);
//REGISTER_ACCESSOR(p, v4, autoRotate, autoRotate);
//REGISTER_ACCESSOR(p, v4, animIdx, animationIndex);
//REGISTER_ACCESSOR(p, v4, frameDuration, frameDuration);
//REGISTER_ACCESSOR(p, v4, frameAt, frameAt);
//REGISTER_ACCESSOR(p, v4, frameCount, frameCount);
//REGISTER_ACCESSOR(p, v4, animT, animationT);
//REGISTER_ACCESSOR(p, v4, r, r);
//REGISTER_ACCESSOR(p, v4, update, update);
//REGISTER_ACCESSOR(p, v4, curX, x);
//REGISTER_ACCESSOR(p, v4, curVX, vx);
//REGISTER_ACCESSOR(p, v4, curAX, ax);
//REGISTER_ACCESSOR(p, v4, curY, y);
//REGISTER_ACCESSOR(p, v4, curVY, vy);
//REGISTER_ACCESSOR(p, v4, curAY, ay);
//REGISTER_ACCESSOR(p, v4, red, red);
//REGISTER_ACCESSOR(p, v4, green, green);
//REGISTER_ACCESSOR(p, v4, blue, blue);
//REGISTER_ACCESSOR(p, v4, alpha, alpha);

Affector {
    // 边界区域，在这个区域内才会处理粒子的边界碰撞
    property int edgeSize: 10
    // 粒子碰撞时的速度衰减比例
    property real velocityFactor: 1.1
    // 每次碰撞减少的生命值，单位为秒
    property real lifeElapse: 2
    // 忽略粒子的margins，取值范围为 0-1，忽略的像素 = particleMargins * particle.startSize
    // 在任何需要使用粒子大小的地方都会减去此margins
    property real particleMargins: 0
    // 粒子出生时间不大于此时间时不对其计算内部碰撞，防止例子被阻塞在发射口
    property real safeLife: 3
    // 安全区域，处于此区域内的且出生时间小于安全时间的粒子不计算内部碰撞
    property rect safeArea
    // 用于计算粒子之间的碰撞信息，求最大碰撞深度（两个物体重合部分的最大宽度），并且返回碰撞点
    // 默认的方法是用来处理圆形
    property var intersectInfo: function intersectSize(c1, c2) {
        // 圆心的距离
        var pd = Qt.vector2d(c1.x - c2.x, c1.y - c2.y).length();
        var depth = (d_ptr.particleSize(c2) + d_ptr.particleSize(c1)) / 2 - pd;

        // 圆之间未相交时直接返回
        if (depth <= 0) {
            return;
        }

        return {
            "depth": depth,
            "point": Qt.point(c2.x - (c2.x - c1.x) * d_ptr.particleSize(c2) / pd / 2,
                              c2.y - (c2.y - c1.y) * d_ptr.particleSize(c2) / pd / 2)
        }
    }
    // 上一次处理的粒子数量
    property int lastAffectParticleCount: 0
    // 屏幕缩放系数
    property real devicePixelRatio: 1

    // 粒子之间碰撞时通知，只通知内部碰撞
    signal impacted(var p1, var p2)

    QtObject {
        id: d_ptr

        // 为粒子分配 id
        property int particleId: 0

        function particleSize(particle) {
            // 粒子的大小不受屏幕缩放系数的控制，所以需要处理后再计算
            return particle.startSize / devicePixelRatio * (1 - particleMargins);
        }

        function rectContains(rect, point) {
            return rect.x <= point.x && rect.y <= point.y && rect.right >= point.x && rect.bottom >= point.y;
        }

        function edgeBounce(particle) {
            var thatRect = Qt.rect(parent.x, parent.y, parent.width, parent.height)
            // 判断是不是从外部进来的粒子
            var isNewcome = particle.id === undefined;

            // 新生成或者新从外部跑到内部的粒子
            if (isNewcome) {
                // 如果粒子出生地点是内部
                if (rectContains(thatRect, Qt.point(particle.initialX, particle.initialY))) {
                    // 为新生成的粒子分配 id
                    particle.id = particleId++;
                    isNewcome = false;
                }
            }

            // 粒子的x y是它的中心，计算这个点和四个边界的距离，处于边界范围时处理其速度
            // 下一帧的位置，假定为60帧
            var next_x = particle.x + particle.vx / 60;
            var next_y = particle.y + particle.vy / 60;

            if (Math.abs(particle.x - thatRect.x) < edgeSize || next_x <= thatRect.x) {
                particle.vx = (isNewcome ? -1 : 1) * Math.abs(particle.vx / velocityFactor);
            } else if (Math.abs(particle.x - thatRect.right) < edgeSize || next_x >= thatRect.right) {
                particle.vx = (isNewcome ? 1 : -1) * Math.abs(particle.vx / velocityFactor);
            }

            if (Math.abs(particle.y - thatRect.y) < edgeSize || next_y <= thatRect.y) {
                particle.vy = (isNewcome ? -1 : 1) * Math.abs(particle.vy / velocityFactor);
            } else if (Math.abs(particle.y - thatRect.bottom) < edgeSize || next_y >= thatRect.bottom) {
                particle.vy = (isNewcome ? 1 : -1) * Math.abs(particle.vy / velocityFactor);
            }
        }

        function particleBouce(particle, particles, i) {
            if (particle.t <= safeLife && (!safeArea || rectContains(safeArea, Qt.point(particle.x, particle.y)))) {
                return;
            }

            var isUpdateing = particle.update;

            // 清理粒子的状态，如果下面检测到其和其它粒子存在交叉时会重新将状态置为true
            particle.update = false;
            // 遍历剩余的所有粒子，找出和当前粒子产生碰撞的进行处理
            for (var j = i + 1; j < particles.length; ++j) {
                var p2 = particles[j];

                if (p2.t <= safeLife && (!safeArea || rectContains(safeArea, Qt.point(p2.x, p2.y)))) {
                    continue;
                }

                // 如果粒子已经处理碰撞更新状态，则忽略它
                if (p2.update) {
                    continue;
                }

                // 得到粒子的相交信息
                var ii = intersectInfo(particle, p2);

                if (!ii) {
                    continue;
                }

                // 标记粒子已经进入碰撞状态
                particle.update = true;

                // 如果粒子原本已经是碰撞状态
                if (isUpdateing) {
                    continue;
                }

                // 当两个粒子相交过大时，忽略其碰撞属性，让这对好基友能再愉快的生活一段时间，直到它们由于自身速度的不一致而分开
                // 在这之前由于没有检测到粒子当前存在好基友而导致的碰撞概不负责
                if (ii.depth > edgeSize) {
                    return;
                }

                // 下面开始对粒子进行力的分解，以particle粒子的startSize作为粒子质量基本单位
                // 所以，粒子p在x y方向上所携带的动能为(用矢量表示)：
                var p1px = Qt.vector2d(particle.vx, 0);
                var p1py = Qt.vector2d(0, particle.vy);
                var p2px = Qt.vector2d(p2.vx * d_ptr.particleSize(p2) / d_ptr.particleSize(particle), 0);
                var p2py = Qt.vector2d(0, p2.vy * d_ptr.particleSize(p2) / d_ptr.particleSize(particle));

                // 接下来求出粒子在碰撞方向所携带的动能，根据初中物理做力的分解:
                // 我们假设粒子的中心点x y为其重心，则重心到碰撞点为粒子对基友碰撞所产生的力的方向
                // 另外再假设粒子间的碰撞为完全弹性碰撞，根据能量守恒定律，粒子会把碰撞方向上的所有动能都传递给对方
                // 另外，自己会保留和碰撞方向垂直方向上的动能，假设两个粒子在各自碰撞方向所产生的动能为p1pi p2pi
                // 则粒子碰撞后的动能为：（np1p np2p为粒子p1 p2碰撞后的新动能，下面的式子为向量表示）
                // np1p = p1px + p1py - p1pi + p2pi
                // np2p = p2px + p2py - p2pi + p1pi

                // 先将粒子x和y方向的力分解为碰撞方向和其垂直方向的力, ixi表示x力在碰撞方向的力，ixj 表示x在碰撞垂直方向的力
                // 相应的y方向上的力把x换成y表示，先用其基本项目表示（标量为1的向量），再计算实际向量
                var p1pixi = Qt.vector2d(ii.point.x - particle.x, ii.point.y - particle.y).normalized();
                var p1piyi = p1py.times(p1pixi);

                // 计算力的实际大小
                p1pixi = p1px.times(p1pixi);

                var p1pixj = p1px.minus(p1pixi);
                var p1piyj = p1py.minus(p1piyi);

                // 接着用同样的方式求粒子2的各项值
                var p2pixi = Qt.vector2d(ii.point.x - p2.x, ii.point.y - p2.y).normalized();
                var p2piyi = p2py.times(p2pixi);

                // 计算力的实际大小
                p2pixi = p2px.times(p2pixi);

                var p2pixj = p2px.minus(p2pixi);
                var p2piyj = p2py.minus(p2piyi);

                // 接下来交换两个粒子在碰撞方向上的力
                // 再将交换后的力合并会x y方向
                p1px = p1pixi.plus(p1pixj);
                p1py = p1piyi.plus(p1piyj);
                p2px = p2pixi.plus(p2pixj);
                p2py = p2piyi.plus(p2piyj);

//                var oldPower = (Math.abs(particle.vx) + Math.abs(particle.vy)) * d_ptr.particleSize(particle)
//                                + (Math.abs(p2.vx) + Math.abs(p2.vy)) * d_ptr.particleSize(p2);
//                console.log(particle.vx, particle.vy, p2.vx, p2.vy, oldPower)

                // 重新设置粒子的速度, 快速衰减速度
                particle.vx = p2px.x / velocityFactor / velocityFactor;
                particle.vy = p2py.y / velocityFactor / velocityFactor;
                p2.vx = p1px.x / d_ptr.particleSize(p2) * d_ptr.particleSize(particle) / velocityFactor / velocityFactor;
                p2.vy = p1py.y / d_ptr.particleSize(p2) * d_ptr.particleSize(particle) / velocityFactor / velocityFactor;

//                var newPower = (Math.abs(particle.vx) + Math.abs(particle.vy)) * d_ptr.particleSize(particle)
//                                + (Math.abs(p2.vx) + Math.abs(p2.vy)) * d_ptr.particleSize(p2);

//                console.log(particle.vx, particle.vy, p2.vx, p2.vy, newPower)
//                console.log(p2.vx, p2.vy, p2px.x, p2py.y, p2px, p2py)

//                if (oldPower != newPower) {
//                    console.log("--------------", newPower - oldPower)
//                }

                // 接下来处理碰撞后的生命值
                particle.lifeSpan -= lifeElapse;
                p2.lifeSpan -= lifeElapse;

                // 通知外部粒子碰撞已经发生
                impacted(particle, p2)

                // 一次只允许这个粒子与别的粒子碰撞一次
                return;
            }
        }
    }

    onAffectParticles: {
        for (var i = 0; i < particles.length; ++i) {
            var particle = particles[i];

            // 处理粒子之间的碰撞
            d_ptr.particleBouce(particle, particles, i)
            // 处理粒子到达边缘情况
            d_ptr.edgeBounce(particle);
        }

        lastAffectParticleCount = particles.length
    }
}
