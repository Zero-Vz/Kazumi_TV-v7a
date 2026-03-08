import 'package:flutter/services.dart';
import 'package:kazumi/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/pages/popular/popular_controller.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:card_settings_ui/card_settings_ui.dart';

class DanmakuSettingsPage extends StatefulWidget {
  const DanmakuSettingsPage({super.key});

  @override
  State<DanmakuSettingsPage> createState() => _DanmakuSettingsPageState();
}

class _DanmakuSettingsPageState extends State<DanmakuSettingsPage> {
  Box setting = GStorage.setting;
  final PopularController popularController = Modular.get<PopularController>();
  
  // 开关类状态保持在主页面，滑条类参数移入单独页面以适配 TV 焦点
  late bool danmakuBorder;
  late bool danmakuTop;
  late bool danmakuBottom;
  late bool danmakuScroll;
  late bool danmakuColor;
  late bool danmakuMassive;
  late bool danmakuDeduplication; // 新版：弹幕去重
  late bool danmakuBiliBiliSource;
  late bool danmakuGamerSource;
  late bool danmakuDanDanSource;
  late bool danmakuFollowSpeed;   // 新版：弹幕跟随视频倍速

  @override
  void initState() {
    super.initState();
    danmakuBorder = setting.get(SettingBoxKey.danmakuBorder, defaultValue: true);
    danmakuTop = setting.get(SettingBoxKey.danmakuTop, defaultValue: true);
    danmakuBottom = setting.get(SettingBoxKey.danmakuBottom, defaultValue: false);
    danmakuScroll = setting.get(SettingBoxKey.danmakuScroll, defaultValue: true);
    danmakuColor = setting.get(SettingBoxKey.danmakuColor, defaultValue: true);
    danmakuMassive = setting.get(SettingBoxKey.danmakuMassive, defaultValue: false);
    danmakuDeduplication = setting.get(SettingBoxKey.danmakuDeduplication, defaultValue: false);
    danmakuBiliBiliSource = setting.get(SettingBoxKey.danmakuBiliBiliSource, defaultValue: true);
    danmakuGamerSource = setting.get(SettingBoxKey.danmakuGamerSource, defaultValue: true);
    danmakuDanDanSource = setting.get(SettingBoxKey.danmakuDanDanSource, defaultValue: true);
    danmakuFollowSpeed = setting.get(SettingBoxKey.danmakuFollowSpeed, defaultValue: true);
  }

  void onBackPressed(BuildContext context) {
    if (KazumiDialog.observer.hasKazumiDialog) {
      KazumiDialog.dismiss();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontFamily = Theme.of(context).textTheme.bodyMedium?.fontFamily;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        onBackPressed(context);
      },
      child: Scaffold(
        appBar: const SysAppBar(title: Text('弹幕设置')),
        body: SettingsList(
          maxWidth: 1000,
          sections: [
            SettingsSection(
              title: Text('弹幕来源', style: TextStyle(fontFamily: fontFamily)),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuBiliBiliSource = value ?? !danmakuBiliBiliSource;
                    await setting.put(SettingBoxKey.danmakuBiliBiliSource, danmakuBiliBiliSource);
                    setState(() {});
                  },
                  title: Text('BiliBili', style: TextStyle(fontFamily: fontFamily)),
                  initialValue: danmakuBiliBiliSource,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuGamerSource = value ?? !danmakuGamerSource;
                    await setting.put(SettingBoxKey.danmakuGamerSource, danmakuGamerSource);
                    setState(() {});
                  },
                  title: Text('Gamer', style: TextStyle(fontFamily: fontFamily)),
                  initialValue: danmakuGamerSource,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuDanDanSource = value ?? !danmakuDanDanSource;
                    await setting.put(SettingBoxKey.danmakuDanDanSource, danmakuDanDanSource);
                    setState(() {});
                  },
                  title: Text('DanDan', style: TextStyle(fontFamily: fontFamily)),
                  initialValue: danmakuDanDanSource,
                ),
              ],
            ),
            SettingsSection(
              title: Text('弹幕屏蔽', style: TextStyle(fontFamily: fontFamily)),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    Modular.to.pushNamed('/settings/danmaku/shield');
                  },
                  title: Text('关键词屏蔽', style: TextStyle(fontFamily: fontFamily)),
                ),
              ],
            ),
            SettingsSection(
              title: Text('高级设置 (TV 专用)', style: TextStyle(fontFamily: fontFamily)),
              tiles: [
                // 跳转到独立的参数调整页面，彻底解决 Slider 与列表上下滚动的焦点冲突
                SettingsTile.navigation(
                  onPressed: (_) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const _DanmakuAdjustPage()));
                  },
                  title: Text('弹幕参数调整', style: TextStyle(fontFamily: fontFamily)),
                  description: Text('字体大小、描边粗细、防挡滑条等', 
                      style: TextStyle(fontFamily: fontFamily)),
                ),
              ],
            ),
            SettingsSection(
              title: Text('显示开关', style: TextStyle(fontFamily: fontFamily)),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuFollowSpeed = value ?? !danmakuFollowSpeed;
                    await setting.put(SettingBoxKey.danmakuFollowSpeed, danmakuFollowSpeed);
                    setState(() {});
                  },
                  title: Text('弹幕跟随视频倍速', style: TextStyle(fontFamily: fontFamily)),
                  description: Text('开启后弹幕速度会随视频倍速而改变', style: TextStyle(fontFamily: fontFamily)),
                  initialValue: danmakuFollowSpeed,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuTop = value ?? !danmakuTop;
                    await setting.put(SettingBoxKey.danmakuTop, danmakuTop);
                    setState(() {});
                  },
                  title: Text('顶部弹幕', style: TextStyle(fontFamily: fontFamily)),
                  initialValue: danmakuTop,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuBottom = value ?? !danmakuBottom;
                    await setting.put(SettingBoxKey.danmakuBottom, danmakuBottom);
                    setState(() {});
                  },
                  title: Text('底部弹幕', style: TextStyle(fontFamily: fontFamily)),
                  initialValue: danmakuBottom,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuScroll = value ?? !danmakuScroll;
                    await setting.put(SettingBoxKey.danmakuScroll, danmakuScroll);
                    setState(() {});
                  },
                  title: Text('滚动弹幕', style: TextStyle(fontFamily: fontFamily)),
                  initialValue: danmakuScroll,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuMassive = value ?? !danmakuMassive;
                    await setting.put(SettingBoxKey.danmakuMassive, danmakuMassive);
                    setState(() {});
                  },
                  title: Text('海量弹幕', style: TextStyle(fontFamily: fontFamily)),
                  description: Text('弹幕过多时进行叠加绘制', style: TextStyle(fontFamily: fontFamily)),
                  initialValue: danmakuMassive,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuDeduplication = value ?? !danmakuDeduplication;
                    await setting.put(SettingBoxKey.danmakuDeduplication, danmakuDeduplication);
                    setState(() {});
                  },
                  title: Text('弹幕去重', style: TextStyle(fontFamily: fontFamily)),
                  description: Text('相同内容弹幕过多时合并为一条弹幕', style: TextStyle(fontFamily: fontFamily)),
                  initialValue: danmakuDeduplication,
                ),
              ],
            ),
            SettingsSection(
              title: Text('样式开关', style: TextStyle(fontFamily: fontFamily)),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuBorder = value ?? !danmakuBorder;
                    await setting.put(SettingBoxKey.danmakuBorder, danmakuBorder);
                    setState(() {});
                  },
                  title: Text('弹幕描边', style: TextStyle(fontFamily: fontFamily)),
                  initialValue: danmakuBorder,
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    danmakuColor = value ?? !danmakuColor;
                    await setting.put(SettingBoxKey.danmakuColor, danmakuColor);
                    setState(() {});
                  },
                  title: Text('弹幕颜色', style: TextStyle(fontFamily: fontFamily)),
                  initialValue: danmakuColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 独立的弹幕参数调整页面 (专为 TV 遥控器优化)
class _DanmakuAdjustPage extends StatefulWidget {
  const _DanmakuAdjustPage();

  @override
  State<_DanmakuAdjustPage> createState() => _DanmakuAdjustPageState();
}

class _DanmakuAdjustPageState extends State<_DanmakuAdjustPage> {
  Box setting = GStorage.setting;
  late double danmakuArea;
  late double danmakuOpacity;
  late double danmakuFontSize;
  late int danmakuFontWeight;
  late double danmakuDuration;
  late double danmakuLineHeight;
  late double danmakuBorderSize; // 新版：弹幕描边粗细
  late double tvBlankSlider;     // 专门加回的空白滑条
  
  @override
  void initState() {
    super.initState();
    danmakuArea = setting.get(SettingBoxKey.danmakuArea, defaultValue: 1.0);
    danmakuOpacity = setting.get(SettingBoxKey.danmakuOpacity, defaultValue: 1.0);
    danmakuFontSize = setting.get(SettingBoxKey.danmakuFontSize, defaultValue: (Utils.isCompact()) ? 16.0 : 25.0);
    danmakuFontWeight = setting.get(SettingBoxKey.danmakuFontWeight, defaultValue: 4);
    danmakuDuration = setting.get(SettingBoxKey.danmakuDuration, defaultValue: 8.0);
    danmakuLineHeight = setting.get(SettingBoxKey.danmakuLineHeight, defaultValue: 1.6);
    danmakuBorderSize = setting.get(SettingBoxKey.danmakuBorderSize, defaultValue: 1.5);
    // 恢复防挡空白滑条状态（使用一个单独的 key 保存）
    tvBlankSlider = setting.get('tv_blank_slider_dummy', defaultValue: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final fontFamily = Theme.of(context).textTheme.bodyMedium?.fontFamily;
    return Scaffold(
      appBar: const SysAppBar(title: Text('弹幕参数调整')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('显示调整', style: TextStyle(fontFamily: fontFamily)),
            tiles: [
              SettingsTile(
                title: Text('弹幕区域', style: TextStyle(fontFamily: fontFamily)),
                description: _TvSlider(
                  value: danmakuArea,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  label: '${(danmakuArea * 100).round()}%',
                  onChanged: (value) async {
                    setState(() => danmakuArea = value);
                    await setting.put(SettingBoxKey.danmakuArea, value);
                  },
                ),
              ),
              SettingsTile(
                title: Text('弹幕持续时间', style: TextStyle(fontFamily: fontFamily)),
                description: _TvSlider(
                  value: danmakuDuration,
                  min: 2,
                  max: 16,
                  divisions: 14,
                  label: '${danmakuDuration.round()}秒',
                  onChanged: (value) async {
                    setState(() => danmakuDuration = value.roundToDouble());
                    await setting.put(SettingBoxKey.danmakuDuration, value.roundToDouble());
                  },
                ),
              ),
              SettingsTile(
                title: Text('弹幕行高', style: TextStyle(fontFamily: fontFamily)),
                description: _TvSlider(
                  value: danmakuLineHeight,
                  min: 0,
                  max: 3,
                  divisions: 30,
                  label: danmakuLineHeight.toStringAsFixed(1),
                  onChanged: (value) async {
                    double val = double.parse(value.toStringAsFixed(1));
                    setState(() => danmakuLineHeight = val);
                    await setting.put(SettingBoxKey.danmakuLineHeight, val);
                  },
                ),
              ),
            ],
          ),
          SettingsSection(
            title: Text('样式调整', style: TextStyle(fontFamily: fontFamily)),
            tiles: [
              SettingsTile(
                title: Text('弹幕描边粗细', style: TextStyle(fontFamily: fontFamily)),
                description: _TvSlider(
                  value: danmakuBorderSize,
                  min: 0.1,
                  max: 3,
                  divisions: 29,
                  label: danmakuBorderSize.toStringAsFixed(1),
                  onChanged: (value) async {
                    double val = double.parse(value.toStringAsFixed(1));
                    setState(() => danmakuBorderSize = val);
                    await setting.put(SettingBoxKey.danmakuBorderSize, val);
                  },
                ),
              ),
              SettingsTile(
                title: Text('字体大小', style: TextStyle(fontFamily: fontFamily)),
                description: _TvSlider(
                  value: danmakuFontSize,
                  min: 10,
                  max: Utils.isCompact() ? 32 : 48,
                  label: '${danmakuFontSize.floor()}',
                  step: 1.0,
                  onChanged: (value) async {
                    setState(() => danmakuFontSize = value.floorToDouble());
                    await setting.put(SettingBoxKey.danmakuFontSize, value.floorToDouble());
                  },
                ),
              ),
              SettingsTile(
                title: Text('字体字重', style: TextStyle(fontFamily: fontFamily)),
                description: _TvSlider(
                  value: danmakuFontWeight.toDouble(),
                  min: 1,
                  max: 9,
                  divisions: 8,
                  label: '$danmakuFontWeight',
                  onChanged: (value) async {
                    setState(() => danmakuFontWeight = value.toInt());
                    await setting.put(SettingBoxKey.danmakuFontWeight, value.toInt());
                  },
                ),
              ),
              SettingsTile(
                title: Text('字体不透明度', style: TextStyle(fontFamily: fontFamily)),
                description: _TvSlider(
                  value: danmakuOpacity,
                  min: 0.1,
                  max: 1,
                  step: 0.05,
                  label: '${(danmakuOpacity * 100).round()}%',
                  onChanged: (value) async {
                    double val = double.parse(value.toStringAsFixed(2));
                    setState(() => danmakuOpacity = val);
                    await setting.put(SettingBoxKey.danmakuOpacity, val);
                  },
                ),
              ),
              // 为你恢复的在旧版底部的特定向右滑动空白区域
              SettingsTile(
                title: Text('空白滑条 (防止阻挡底部UI)', style: TextStyle(fontFamily: fontFamily, color: Colors.grey)),
                description: _TvSlider(
                  value: tvBlankSlider,
                  min: 0,
                  max: 100,
                  step: 10,
                  label: '防挡拉条 ${tvBlankSlider.round()}',
                  onChanged: (value) async {
                    setState(() => tvBlankSlider = value);
                    await setting.put('tv_blank_slider_dummy', value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 适用于 TV 的 Slider
/// 1. 强制拦截左右按键
/// 2. 获焦时自动滚动到可视区域
/// 3. 获焦时显式显示数值 Label
class _TvSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final ValueChanged<double>? onChanged;
  final double? step;

  const _TvSlider({
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.label,
    this.onChanged,
    this.step,
  });

  @override
  State<_TvSlider> createState() => _TvSliderState();
}

class _TvSliderState extends State<_TvSlider> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange(bool hasFocus) {
    if (hasFocus) {
      // 关键修复：当获得焦点时，确保控件在屏幕中间
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
      );
      setState(() {});
    } else {
      setState(() {});
    }
  }

  void _changeValue(bool isIncrease) {
    if (widget.onChanged == null) return;

    double stepValue;
    if (widget.divisions != null && widget.divisions! > 0) {
      stepValue = (widget.max - widget.min) / widget.divisions!;
    } else {
      stepValue = widget.step ?? (widget.max - widget.min) / 10.0;
    }

    double newValue =
        isIncrease ? widget.value + stepValue : widget.value - stepValue;

    // 防止浮点数精度问题
    newValue = double.parse(newValue.toStringAsFixed(2));

    if (newValue < widget.min) newValue = widget.min;
    if (newValue > widget.max) newValue = widget.max;

    if (newValue != widget.value) {
      widget.onChanged!(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = _focusNode.hasFocus;
    final theme = Theme.of(context);

    return Focus(
      focusNode: _focusNode,
      onFocusChange: _onFocusChange,
      // 使用 onKey 强制拦截，避免事件冒泡导致列表滚动
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _changeValue(false);
            return KeyEventResult.handled; // 明确告知系统已处理，不再传递
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _changeValue(true);
            return KeyEventResult.handled; // 明确告知系统已处理，不再传递
          }
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 显式数值显示：仅在获得焦点时出现
          if (hasFocus && widget.label != null)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.label!,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Slider(
            value: widget.value,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: null,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
